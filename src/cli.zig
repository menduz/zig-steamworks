extern "C" fn dump_all() callconv(.c) c_int;

pub fn main() !void {
    _ = dump_all();
}
