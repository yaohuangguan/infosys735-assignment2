"""Static offline CloudFormation checks (PyYAML optional).

AWS CloudFormation validate-template is still required before deployment.
"""
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
try:
    import yaml
except ImportError:
    yaml=None

@unittest.skipIf(yaml is None, "Install PyYAML to run offline YAML structure tests")
class TemplateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        class CfnLoader(yaml.SafeLoader):
            pass
        def intrinsic(loader, tag, node):
            if isinstance(node,yaml.ScalarNode):
                return {"!"+tag:loader.construct_scalar(node)}
            if isinstance(node,yaml.SequenceNode):
                return {"!"+tag:loader.construct_sequence(node)}
            return {"!"+tag:loader.construct_mapping(node)}
        CfnLoader.add_multi_constructor("!",intrinsic)
        cls.doc=yaml.load((ROOT/"template.yaml").read_text(),Loader=CfnLoader)
        cls.resources=cls.doc["Resources"]

    def test_nat_public_nacl_allows_vpc_https(self):
        r=self.resources["PublicNaclInHttpsFromVpc"]["Properties"]
        self.assertEqual(r["CidrBlock"],"10.0.0.0/16")
        self.assertEqual(r["RuleAction"],"allow")
        self.assertEqual(r["PortRange"],{"From":443,"To":443})
        self.assertFalse(r["Egress"])

    def test_cpu_alarm_five_minute_basic_monitoring(self):
        p=self.resources["FrontendHighCpuAlarm"]["Properties"]
        self.assertEqual(p["Period"],300)
        self.assertEqual(p["EvaluationPeriods"],2)
        self.assertEqual(p["Threshold"],70)

    def test_optional_sns_subscription(self):
        self.assertIn("AlarmNotificationEmail",self.doc["Parameters"])
        self.assertIn("HasAlarmNotificationEmail",self.doc["Conditions"])
        s=self.resources["AlarmEmailSubscription"]
        self.assertEqual(s["Condition"],"HasAlarmNotificationEmail")
        self.assertEqual(s["Properties"]["Protocol"],"email")

    def test_asg_and_db_boundary(self):
        self.assertEqual(self.resources["FrontendASG"]["Properties"]["DesiredCapacity"],"2")
        self.assertEqual(self.resources["BackendASG"]["Properties"]["DesiredCapacity"],"2")
        self.assertEqual(self.resources["DummyDb"]["Type"],"AWS::EC2::Instance")
        self.assertNotIn("OracleDatabase",self.resources)

if __name__=="__main__":
    unittest.main()
