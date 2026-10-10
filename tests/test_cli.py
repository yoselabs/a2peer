import pytest

from a2peer import main


def test_main_says_not_built_yet(capsys: pytest.CaptureFixture[str]) -> None:
    main()
    assert "not built yet" in capsys.readouterr().out
