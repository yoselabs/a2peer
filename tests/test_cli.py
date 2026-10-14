import subprocess
import sys

import pytest

from a2peer import main


def test_main_says_not_built_yet(capsys: pytest.CaptureFixture[str]) -> None:
    main([])
    assert "not built yet" in capsys.readouterr().out


def test_script_help_exits_zero_and_prints_usage() -> None:
    result = subprocess.run([sys.executable, "-m", "a2peer", "--help"], capture_output=True, text=True, check=False)
    assert result.returncode == 0
    assert "usage" in result.stdout.lower()


def test_script_unknown_flag_exits_two() -> None:
    result = subprocess.run([sys.executable, "-m", "a2peer", "--nope"], capture_output=True, text=True, check=False)
    assert result.returncode == 2
