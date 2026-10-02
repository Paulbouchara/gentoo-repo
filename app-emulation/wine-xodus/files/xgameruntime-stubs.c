
HRESULT WINAPI DllCanUnloadNow(void)
{
    TRACE( "()\n" );
    return S_OK;
}

HRESULT WINAPI UninitializeApiImpl(void)
{
    TRACE( "()\n" );
    return S_OK;
}

HRESULT WINAPI XErrorReport(HRESULT hr, const char *str)
{
    TRACE( "hr %#lx, str %s\n", hr, debugstr_a(str) );
    return S_OK;
}
