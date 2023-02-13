const std = @import("std");
const Gnome = @import("vm.zig");
const op = Gnome.op;

pub fn main() !void {
        var code = [_]u8 {
        //main(x)
        op(.push), 9,
        op(.call), 5,
        op(.halt),

        // sqaure(x)
        op(.load), 1,
        op(.load), 1,
        op(.mul),
        op(.halt)
        
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var vm = Gnome.init(allocator, code[0..code.len]);

    try vm.run();
}
