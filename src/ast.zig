const std = @import("std");
const Allocator = std.mem.Allocator;
const mem = std.mem;
const OpCode = @import("vm.zig").OpCode;


pub const TreeNode = struct {
    const Self = @This();

    pub const Tag = enum(u8) {
        program,
        add,
        sub,
        mul,
        div,
        intLiteral,
    };

    left: ?*TreeNode = null,
    right: ?*TreeNode = null,

    tag: Tag,
    value: i32,
    



    pub fn addLeft(branch: *TreeNode, leaf: TreeNode, allocator: Allocator) !void {
        var result = try allocator.create(TreeNode);
        result.* = leaf;
        branch.left = result;
    }

    pub fn addRight(self: *Self, leaf: TreeNode, allocator: Allocator) !void {
        var result = try allocator.create(TreeNode);
        result.* = leaf;
        self.right = result;
    }

    pub fn interpret(self: *Self) i32 {
        var leftValue: i32 = 0;
        var rightValue: i32 = 0;

        if (self.right) |right| {
            rightValue = right.interpret();
        } if (self.left) |left| {
            leftValue = left.interpret();
        }
        var result: i32 = undefined;
        switch (self.tag) {
            .program => result = leftValue,
            .intLiteral => result = self.value,
            .add => result = leftValue + rightValue,
            .sub => result = leftValue - rightValue,
            .mul => result = leftValue * rightValue,
            .div => result = @divFloor(leftValue, rightValue),
            // else => unreachable,
        }

        // std.debug.print("result: {}\n", .{result});
        return result;
    }

    pub fn emitCode(self: *Self, buffer: *std.ArrayList(u8)) !void {
        switch (self.tag) {
            .program => {
                if (self.left) |left| try left.emitCode(buffer);
                try buffer.append(@enumToInt(OpCode.halt));
            },
            .intLiteral => {
                try buffer.append(@enumToInt(OpCode.push));
                try buffer.append(@intCast(u8, self.value));
            },
            .add => {
                if (self.left) |left| 
                    try left.emitCode(buffer);
                if (self.right) |right| 
                    try right.emitCode(buffer);
                try buffer.append(@enumToInt(OpCode.add));
            },
            .sub => {
                if (self.left) |left| 
                    try left.emitCode(buffer);
                if (self.right) |right| 
                    try right.emitCode(buffer);
                try buffer.append(@enumToInt(OpCode.sub));
            },
            .mul => {
                if (self.left) |left| 
                    try left.emitCode(buffer);
                if (self.right) |right| 
                    try right.emitCode(buffer);
                try buffer.append(@enumToInt(OpCode.mul));
            },
            .div => {
                if (self.left) |left| 
                    try left.emitCode(buffer);
                if (self.right) |right| 
                    try right.emitCode(buffer);
                try buffer.append(@enumToInt(OpCode.div));
            },

            // else => unreachable
        }

        // std.debug.print("Code:\n", .{});
        // for (buffer.items) |value| {
        //     std.debug.print("{}\n", .{value});
        // }
    }
};

test "ast" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocatorGPA = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocatorGPA);
    const allocator = arena.allocator();
    defer arena.deinit();
    
    var root: *TreeNode = try allocator.create(TreeNode);
    
    // std.debug.print("\n{}\n", .{@TypeOf(root)});

    root.* = TreeNode {
        .left = null,
        .right = null,
        .value = 0,
        .tag = .program,
    };

    // std.debug.print("{}\n", .{root.*});
    
    try root.addLeft(
        TreeNode {
            .left = null,
            .right = null,
            .value = 0,
            .tag = .mul,
        },
        allocator
    );
    
    if (root.left) |left| {
        try left.addLeft(
            TreeNode {
                .left = null,
                .right = null,
                .value = 23,
                .tag = .intLiteral,
            },
            allocator
        );
        try left.addRight(
            TreeNode {
                .left = null,
                .right = null,
                .value = 3,
                .tag = .intLiteral,
            },
            allocator
        );
        
    }


    
    // if (root.left) |left| 
    //     std.debug.print("{}\n", .{left});
    // if (root.right) |right| 
    //     std.debug.print("{}\n", .{right});
    const Gnome = @import("vm.zig");
    var code = std.ArrayList(u8).init(allocatorGPA);
    try root.emitCode(&code);

    var vm = Gnome.init(allocatorGPA, code.items[0..code.items.len]);
    try vm.run();
    const answer = root.interpret();

    std.debug.print("\nThe answer = {d}\n", .{answer});


}