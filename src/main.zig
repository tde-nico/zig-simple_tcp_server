const std = @import("std");
const net = std.net;
const stdout = std.io.getStdOut().writer();

fn handleConn(conn: net.Server.Connection) !void {
    defer conn.stream.close();

    var buf: [1024]u8 = undefined;
    const bytes = try conn.stream.read(&buf);
    try stdout.print("[INFO] Recived {d} bytes: {s}\n", .{ bytes, buf[0..bytes] });

    _ = try conn.stream.write(
        \\HTTP/1.1 200 OK
        \\Content-Type: text/html; charset=UTF-8
        \\Content-Length: 2000
        \\
        \\<!DOCTYPE html>
        \\<html>
        \\    <head>
        \\        <title>Web server</title>
        \\    </head>
        \\    <body>
        \\        <h1>My Zig web server</h1>
        \\        <p>hello world!</p>
        \\    </body>
        \\</html>
    );
}

pub fn main() !void {
    const address = try net.Address.resolveIp("0.0.0.0", 3000);
    var server = try address.listen(.{
        .reuse_port = true,
        .reuse_address = true,
    });
    defer server.deinit();

    try stdout.print("[INFO] Listening on {}...\n", .{server.listen_address});

    while (true) {
        const conn = try server.accept();
        errdefer conn.stream.close();

        _ = try std.Thread.spawn(.{}, handleConn, .{conn});
    }
}
