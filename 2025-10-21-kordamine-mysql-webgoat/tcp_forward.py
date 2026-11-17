# Port forwarding host:PORT -> masin:PORT (VirtualBoxi "Port Forwarding" asemel). Jegor Onoprijuk, TA-24B
import socket, sys, threading
lp, host, rp = int(sys.argv[1]), sys.argv[2], int(sys.argv[3])
def pipe(a, b):
    try:
        while (d := a.recv(65536)): b.sendall(d)
    except OSError: pass
    finally:
        for s in (a, b):
            try: s.close()
            except OSError: pass
srv = socket.socket(); srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("127.0.0.1", lp)); srv.listen(20)
while True:
    c, _ = srv.accept()
    try: r = socket.create_connection((host, rp))
    except OSError: c.close(); continue
    threading.Thread(target=pipe, args=(c, r), daemon=True).start(); threading.Thread(target=pipe, args=(r, c), daemon=True).start()
