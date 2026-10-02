#!/usr/bin/env python3
"""
Replaces the get_rps_tickets stub in xuser.c with a file-based
implementation using fopen() (CRT) which handles Unix paths in Wine.
"""
import sys

path = sys.argv[1]
with open(path, 'r') as f:
    content = f.read()

OLD = (
    'static HRESULT get_rps_tickets( BOOLEAN allowUi, char **userTicket, char **deviceTicket )\n'
    '{\n'
    '    FIXME( "allowUi %d, userTicket %p, deviceTicket %p stub!\\n", allowUi, userTicket, deviceTicket );\n'
    '    return E_NOTIMPL;\n'
    '}'
)

NEW = r"""static HRESULT get_rps_tickets( BOOLEAN allowUi, char **userTicket, char **deviceTicket )
{
    /* Read pre-fetched RPS tickets from ~/xodustickets/ (written by get_xodus_tickets.py).
     * We use fopen() rather than CreateFileA() because Wine's CRT fopen() accepts
     * Unix absolute paths directly, whereas CreateFileA() expects Windows drive paths. */
    const char *home;
    char userPath[512];
    char devicePath[512];
    FILE *f;
    long fileSize;
    char *userBuf = NULL, *deviceBuf = NULL;
    size_t bytesRead;
    HRESULT hr = E_FAIL;

    home = getenv( "HOME" );
    if (!home)
    {
        WARN( "get_rps_tickets: HOME not set in environment\n" );
        return E_FAIL;
    }

    snprintf( userPath,   sizeof(userPath),   "%s/xodustickets/user.txt",   home );
    snprintf( devicePath, sizeof(devicePath), "%s/xodustickets/device.txt", home );

    /* -- read user ticket -- */
    f = fopen( userPath, "rb" );
    if (!f) { WARN( "get_rps_tickets: cannot open %s\n", userPath ); goto cleanup; }
    fseek( f, 0, SEEK_END );
    fileSize = ftell( f );
    fseek( f, 0, SEEK_SET );
    if (fileSize <= 0) { fclose( f ); goto cleanup; }
    userBuf = calloc( 1, fileSize + 1 );
    if (!userBuf) { fclose( f ); hr = E_OUTOFMEMORY; goto cleanup; }
    bytesRead = fread( userBuf, 1, fileSize, f );
    fclose( f );
    while (bytesRead > 0 && (userBuf[bytesRead-1] == '\n' || userBuf[bytesRead-1] == '\r'))
        userBuf[--bytesRead] = '\0';
    if (bytesRead == 0) goto cleanup;

    /* -- read device ticket -- */
    f = fopen( devicePath, "rb" );
    if (!f) { WARN( "get_rps_tickets: cannot open %s\n", devicePath ); goto cleanup; }
    fseek( f, 0, SEEK_END );
    fileSize = ftell( f );
    fseek( f, 0, SEEK_SET );
    if (fileSize <= 0) { fclose( f ); goto cleanup; }
    deviceBuf = calloc( 1, fileSize + 1 );
    if (!deviceBuf) { fclose( f ); hr = E_OUTOFMEMORY; goto cleanup; }
    bytesRead = fread( deviceBuf, 1, fileSize, f );
    fclose( f );
    while (bytesRead > 0 && (deviceBuf[bytesRead-1] == '\n' || deviceBuf[bytesRead-1] == '\r'))
        deviceBuf[--bytesRead] = '\0';
    if (bytesRead == 0) goto cleanup;

    *userTicket   = userBuf;   userBuf   = NULL;
    *deviceTicket = deviceBuf; deviceBuf = NULL;
    hr = S_OK;
    TRACE( "get_rps_tickets: loaded tickets from %s and %s\n", userPath, devicePath );

cleanup:
    free( userBuf );
    free( deviceBuf );
    return hr;
}"""

if OLD not in content:
    print(f"ERROR: target function not found in {path}", file=sys.stderr)
    sys.exit(1)

content = content.replace(OLD, NEW)
with open(path, 'w') as f:
    f.write(content)

print(f"Patched get_rps_tickets in {path}")
