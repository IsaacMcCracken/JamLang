const Gnome = @This();

const std = @import("std");
const math = std.math;
const mem = std.mem;
const Allocator = std.mem.Allocator;




pub const OpCode = enum(u8) {

    push,
    pop,

    call,
    ret,
    load,
    stor,

    add,
    sub,
    mul,
    div,

    halt,


};

pub fn op(x: OpCode) u8 {
    return @enumToInt(x);
}


const ValueStack = std.ArrayList(Value);
const FrameStack = std.ArrayList(u32);
const Value = u8;

code: []u8,
stack: [256]Value,
sp: u32,
pc: u32,
valueStack: ValueStack,
frameStack: FrameStack,

pub fn init(allocator: Allocator, code: []u8) Gnome {
    return Gnome {
        .code = code,
        .stack = mem.zeroes([256]Value),
        .sp = 0,
        .pc = 0,
        .valueStack = ValueStack.init(allocator),
        .frameStack = FrameStack.init(allocator),
    };
}



fn binaryOp(self: *Gnome, x: OpCode) void {
    const b = self.stack[self.sp - 1];
    const a = self.stack[self.sp - 2];
    self.sp -= 1;
    const result = switch (x) {
        .add => a + b,
        .sub => a - b,
        .mul => a * b,
        .div => a / b,
        else => unreachable,
    };
    // std.debug.print("{} {} {} = {}", .{a, x, b, result});
    self.stack[self.sp - 1] = result;
}

pub fn run(self: *Gnome) !void {
    var running = true;
    var offset: u32 = 1;

    while (running) : (self.pc += offset) {
        var instruction = @intToEnum(OpCode, self.code[self.pc]);
        offset = 1;
        std.debug.print("Op: {}\n", .{instruction});
        switch (instruction) {
            .push => {
                offset = 2;
                self.stack[self.sp] = self.code[self.pc + 1];
                self.sp += 1;
            },
            .pop => self.sp -= 1,
            

            .add => binaryOp(self, .add),
            .sub => binaryOp(self, .sub),
            .mul => binaryOp(self, .mul),
            .div => binaryOp(self, .div),

            .call => {
                offset = 0;
                try self.valueStack.append(@intCast(u8, self.pc + 2));
                try self.frameStack.append(@intCast(u32, self.valueStack.items.len - 1));

                // load the local variables onto the implicit stack
                var i: u8 = 0;
                while (i < self.sp) : (i += 1) {
                    try self.valueStack.append(self.stack[i]);
                }
                self.sp = 0;

                self.pc = self.code[self.pc + 1];
            },
            .ret => {
                offset = 0;
                var lastFrame = self.frameStack.items[self.frameStack.items.len - 1];
                var returnAddress = self.valueStack.items[lastFrame];

                self.valueStack.items.len = lastFrame;
                self.pc = returnAddress;
            },
            
            .load => {
                offset = 2;
                var index: u32 = self.code[self.pc + 1]; 
                index += self.frameStack.items[self.frameStack.items.len - 1];

                var temp = self.valueStack.items[index];
                self.stack[self.sp] = temp;
                self.sp += 1;
            },
            .stor => {
                offset = 2;
                var index: u32 = self.code[self.pc + 1];
                index += self.frameStack.items[self.frameStack.items.len - 1];

                var variable = self.stack[self.sp - 1];
                self.sp -= 1;

                if (index >= self.valueStack.items.len) {
                    try self.valueStack.append(variable);
                } else {
                    self.valueStack.items[index] = variable;
                }
            },


            .halt => {
                std.debug.print("halting\n", .{});
                return;
            },
            // else => unreachable,
        }
        std.debug.print("offset: {}", .{offset});
        printStack(self);
    }
}

pub fn printStack(self: *Gnome) void {
    std.debug.print("\nStack (pc: {d:2})\n", .{self.pc});
    var i: u8 = 0;
    while (i < self.sp) : (i += 1) {
        std.debug.print("[{d:11}]\n", .{self.stack[i]});
    }
    std.debug.print("\nValue Stack\n", .{});
    for (self.valueStack.items) |value| {
        std.debug.print("[{d:11}]\n", .{value});
    }
}   



// test "zero" {
//     var code = [_]u8 {
//         //main(x)
//         op(.push), 9,
//         op(.call), 5,
//         op(.halt),

//         // sqaure(x)
//         op(.load), 1,
//         op(.load), 1,
//         op(.mul),
//         op(.ret)
        
//     };

//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const allocator = gpa.allocator();

//     var vm = Gnome.init(allocator, code[0..code.len]);

//     try vm.run();

// }

// test "one" {
//     var code = [_]u8 {
//         //main(x)
//         op(.push), 8,
//         op(.call), 5,
//         op(.halt),

//         // add42(x)
//         op(.push), 42,
//         op(.stor), 2,
//         op(.load), 2,
//         op(.load), 1,
//         op(.add),
//         op(.ret)
        
//     };

//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     const allocator = gpa.allocator();

//     var vm = Gnome.init(allocator, code[0..code.len]);

//     try vm.run();

// }
