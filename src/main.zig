const std = @import("std");
const steam = @import("steam.zig");

/// callback hook for debug text emitted from the Steam API
pub fn SteamAPIDebugTextHook(nSeverity: c_int, pchDebugText: [*c]const u8) callconv(.C) void {
    // if you're running in the debugger, only warnings (nSeverity >= 1) will be sent
    // if you add -debug_steamapi to the command-line, a lot of extra informational messages will also be sent
    std.debug.print("SteamAPIDebugTextHook sev:{} msg: {s}\n", .{ nSeverity, pchDebugText });
}

/// get an authentication ticket for our user
fn authTicket(identity: *steam.SteamNetworkingIdentity) !void {
    var rgchToken: *[2048]u8 = try std.heap.c_allocator.create([2048]u8);
    var unTokenLen: c_uint = 0;
    var m_hAuthTicket = steam.SteamUser().GetAuthSessionTicket(rgchToken, 2048, &unTokenLen, identity);
    std.debug.print("GetAuthSessionTicket={} len={} token={s}", .{ m_hAuthTicket, unTokenLen, rgchToken });
}

pub fn main() !void {
    if (steam.SteamAPI_RestartAppIfNecessary(480)) {
        // if Steam is not running or the game wasn't started through Steam, SteamAPI_RestartAppIfNecessary starts the
        // local Steam client and also launches this game again.

        // Once you get a public Steam AppID assigned for this game, you need to replace k_uAppIdInvalid with it and
        // removed steam_appid.txt from the game depot.
        @panic("SteamAPI_RestartAppIfNecessary");
    }

    if (steam.SteamAPI_Init()) {
        std.debug.print("Steam initialized correctly. \n", .{});
    } else {
        @panic("Steam did not init\n");
    }

    steam.SteamClient().SetWarningMessageHook(SteamAPIDebugTextHook);

    defer steam.SteamAPI_Shutdown();

    std.debug.print("User {?}\n", .{steam.SteamUser().GetSteamID()});

    var sock = steam.SteamNetworkingSockets_SteamAPI();

    var pInfo: *steam.SteamNetworkingFakeIPResult_t = try std.heap.c_allocator.create(steam.SteamNetworkingFakeIPResult_t);
    defer std.heap.c_allocator.destroy(pInfo);

    sock.GetFakeIP(0, pInfo);
    std.debug.print("GetFakeIP: {}\n", .{pInfo});
    if (!pInfo.m_identity.IsEqualTo(pInfo.m_identity)) @panic("not equal");

    if (steam.SteamUser().BLoggedOn()) {
        std.debug.print("Current username: {s}\n", .{steam.SteamFriends().GetPersonaName()});
    }

    var pDetails: *steam.SteamNetAuthenticationStatus_t = try std.heap.c_allocator.create(steam.SteamNetAuthenticationStatus_t);
    defer std.heap.c_allocator.destroy(pDetails);

    var connectionStatus = sock.GetAuthenticationStatus(pDetails);
    std.debug.print("GetAuthenticationStatus: {} {}\n", .{ connectionStatus, pDetails });

    var pIdentity: *steam.SteamNetworkingIdentity = try std.heap.c_allocator.create(steam.SteamNetworkingIdentity);
    std.heap.c_allocator.destroy(pIdentity);
    var r = sock.GetIdentity(pIdentity);
    std.debug.print("GetIdentity={} {}\n", .{ r, pIdentity });

    try authTicket(pIdentity);
}
