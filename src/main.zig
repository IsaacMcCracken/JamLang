const std = @import("std");
const process = std.process;


const Gnome = @import("vm.zig");
const Tokenizer = @import("tokenizer.zig");
const op = Gnome.op;



pub fn main() !void {
    var source = "20 + 3 * 3 ";

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // std.debug.print("{s}", .{source});
    var tokenizer = try Tokenizer.init(gpa.allocator(), source);
    try tokenizer.lex();
    tokenizer.tokens.debugPrint();
}
