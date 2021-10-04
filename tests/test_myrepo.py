from myrepolib import repomod


def test_func():
    result = repomod.myfunc()
    assert result == 1
    assert 1 == 2

def test_func_always_fail():
    result = 2
    assert result == 1