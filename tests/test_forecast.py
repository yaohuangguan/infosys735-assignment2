"""Offline tests for the inline CloudFormation Lambda forecast handler.

Run: python3 -m unittest discover -s tests -v
No AWS credentials or infrastructure required.
"""
import io
import json
import sys
import textwrap
import types
import unittest
from pathlib import Path
from urllib.parse import quote_plus

ROOT = Path(__file__).resolve().parents[1]

class FakeS3:
    def __init__(self):
        self.objects = {}
    def get_object(self, Bucket, Key):
        return {"Body": io.BytesIO(self.objects[(Bucket,Key)])}
    def put_object(self, Bucket, Key, Body, ContentType):
        self.objects[(Bucket,Key)] = Body

def load_lambda(fake):
    lines=(ROOT/"template.yaml").read_text().splitlines()
    start=next(i for i,x in enumerate(lines) if x=="        ZipFile: |")
    end=next(i for i in range(start+1,len(lines)) if lines[i].startswith("      Tags:"))
    src=textwrap.dedent("\n".join(lines[start+1:end]))+"\n"
    module=types.ModuleType("boto3")
    module.client=lambda name: fake
    old=sys.modules.get("boto3")
    sys.modules["boto3"]=module
    try:
        namespace={}
        exec(compile(src,"template.yaml:ForecastFunction.Code.ZipFile","exec"),namespace)
    finally:
        if old is None:
            sys.modules.pop("boto3",None)
        else:
            sys.modules["boto3"]=old
    return namespace["lambda_handler"]

SAMPLE=(ROOT/"sample-sales.csv").read_text()
def event(*keys):
    return {"Records":[{"s3":{"bucket":{"name":"demo"},"object":{"key":quote_plus(k)}}} for k in keys]}

class ForecastTests(unittest.TestCase):
    def setUp(self):
        self.fake=FakeS3()
        self.handler=load_lambda(self.fake)
    def run_csv(self,csv_text,key="forecast-input/sales.csv"):
        self.fake.objects[("demo",key)]=csv_text.encode("utf-8")
        return self.handler(event(key),None)
    def test_sample_forecast_and_new_output(self):
        result=self.run_csv(SAMPLE)["results"][0]
        self.assertEqual(result["next_day_sales_forecast"],559.71)
        self.assertEqual(result["window_size"],7)
        self.assertEqual(result["forecast_date"],"2026-09-29")
        self.assertEqual(result["source_key"],"forecast-input/sales.csv")
        self.assertIn(("demo",result["result_key"]),self.fake.objects)
        self.assertIn(("demo","forecast-output/latest.json"),self.fake.objects)
        self.assertEqual(json.loads(self.fake.objects[("demo",result["result_key"])]),result)
    def test_encoded_space_and_plus(self):
        key="forecast-input/shop A+store.csv"
        result=self.run_csv(SAMPLE,key)["results"][0]
        self.assertEqual(result["source_key"],key)
        self.assertIn(("demo",result["result_key"]),self.fake.objects)
    def test_multi_record_event(self):
        self.fake.objects[("demo","forecast-input/a.csv")]=SAMPLE.encode()
        self.fake.objects[("demo","forecast-input/b.csv")]=SAMPLE.encode()
        result=self.handler(event("forecast-input/a.csv","forecast-input/b.csv"),None)
        self.assertEqual(result["processed"],2)
        self.assertEqual(len(result["results"]),2)
    def test_reject_nan_infinity_negative(self):
        for bad in ["NaN","Infinity","-1",""]:
            with self.subTest(bad=bad):
                with self.assertRaises(ValueError):
                    self.run_csv("date,sales\n2026-09-01,1\n2026-09-02,"+bad+"\n")
    def test_reject_missing_or_duplicate_dates(self):
        for csv_text in [
            "date,sales\n2026-09-01,1\n2026-09-03,2\n",
            "date,sales\n2026-09-01,1\n2026-09-01,2\n",
            "date,sales\n2026-09-02,1\n2026-09-01,2\n",
        ]:
            with self.subTest(csv_text=csv_text):
                with self.assertRaises(ValueError):
                    self.run_csv(csv_text)
    def test_reject_bad_schema_and_no_records(self):
        with self.assertRaises(ValueError):
            self.run_csv("sales\n10\n")
        with self.assertRaises(ValueError):
            self.handler({"Records":[]},None)
    def test_small_valid_dataset(self):
        result=self.run_csv("date,sales\n2026-09-01,20\n2026-09-02,40\n")["results"][0]
        self.assertEqual(result["next_day_sales_forecast"],30)
        self.assertEqual(result["window_size"],2)

if __name__=="__main__":
    unittest.main()
