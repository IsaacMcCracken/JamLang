const std = @import("std");
const process = std.process;


const Gnome = @import("vm.zig");
const op = Gnome.op;

pub fn main() !void {
    var a: std.mem.Allocator = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();


    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    a = arena.allocator();
    var arg_it = try process.ArgIterator.initWithAllocator(a);
    
    _ = arg_it.skip();

    const path = arg_it.next();
    if (path) |value| 
        std.debug.print("wowie: {s}\nvalue: {}", .{value, @TypeOf(value)});
        
}
