extern "C" fn dump_all() callconv(.C) c_int;

pub fn main() !void {
    _ = dump_all();
}
