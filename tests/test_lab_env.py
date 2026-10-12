"""Offline validation for the local AWS Academy .env loader (fake keys only)."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
LOADER = ROOT / "scripts" / "load-env.sh"

class LabEnvTests(unittest.TestCase):
    def parse(self, data):
        with tempfile.TemporaryDirectory(prefix="a2-env-test-") as td:
            fixture = Path(td) / "fixture.cfg"
            fixture.write_text(data)
            cmd = [
                "bash", "-c",
                'set -euo pipefail; source "$1"; load_lab_env "$2"; '
                "printf 'ID=%s\\nSECRET=%s\\nTOKEN=%s\\nREGION=%s\\n' "
                '"${AWS_ACCESS_KEY_ID:-}" "${AWS_SECRET_ACCESS_KEY:-}" '
                '"${AWS_SESSION_TOKEN:-}" "${AWS_REGION:-}"',
                "bash", str(LOADER), str(fixture),
            ]
            env = os.environ.copy()
            for k in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"):
                env.pop(k, None)
            return subprocess.run(cmd, capture_output=True, text=True, env=env, timeout=5)

    @staticmethod
    def fields(result):
        return dict(row.split("=", 1) for row in result.stdout.splitlines())

    def test_uppercase_dotenv(self):
        p = self.parse("AWS_ACCESS_KEY_ID=FAKE_ID\nAWS_SECRET_ACCESS_KEY=FAKE_SECRET\n"
                       "AWS_SESSION_TOKEN=FAKE_TOKEN\nAWS_REGION=us-east-1\n")
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(self.fields(p)["ID"], "FAKE_ID")
        self.assertEqual(self.fields(p)["TOKEN"], "FAKE_TOKEN")
        self.assertEqual(self.fields(p)["REGION"], "us-east-1")

    def test_academy_cli_block(self):
        p = self.parse("[default]\naws_access_key_id = TEST1\n"
                       "aws_secret_access_key = S=2\n"
                       "aws_session_token = abc+/=\n")
        self.assertEqual(p.returncode, 0, p.stderr)
        self.assertEqual(self.fields(p)["SECRET"], "S=2")
        self.assertEqual(self.fields(p)["TOKEN"], "abc+/=")

    def test_content_is_not_executed(self):
        with tempfile.TemporaryDirectory(prefix="a2-env-poison-") as td:
            poison = Path(td) / "should-not-exist"
            value = "$(touch " + str(poison) + ")"
            p = self.parse("AWS_ACCESS_KEY_ID='" + value + "'\n"
                           "AWS_SECRET_ACCESS_KEY=FAKE\nAWS_SESSION_TOKEN=FAKE\n")
            self.assertEqual(p.returncode, 0, p.stderr)
            self.assertFalse(poison.exists())
            self.assertEqual(self.fields(p)["ID"], value)

    def test_partial_credentials_rejected(self):
        p = self.parse("AWS_ACCESS_KEY_ID=FAKE\n")
        self.assertNotEqual(p.returncode, 0)
        self.assertIn("requires all three", p.stderr)

    def test_invalid_syntax_rejected(self):
        p = self.parse("THIS IS NOT A KEY VALUE\n")
        self.assertNotEqual(p.returncode, 0)

    def test_no_real_values_in_template(self):
        template = (ROOT / ".env.example").read_text()
        for key in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"):
            self.assertIn(key + "=\n", template)

if __name__ == "__main__":
    unittest.main()
