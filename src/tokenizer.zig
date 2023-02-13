
const Tokenizer = @This();

const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const TreeNode = @import("ast.zig").TreeNode;

source: []const u8,
tokens: Tokens,

pub fn init(allocator: Allocator, source: []const u8) !Tokenizer {
    return Tokenizer {
        .source = source,
        .tokens = Tokens {
            .len = 0,
            .tags = Tokens.TagList.init(allocator),
            .begin = Tokens.U32List.init(allocator),
            .end =  Tokens.U32List.init(allocator),
        },
    };
}

fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

fn appendToken(self: *Tokenizer, tag: Tag, begin: u32, end: u32) !void {
    self.tokens.len += 1;
    try self.tokens.tags.append(tag);
    try self.tokens.begin.append(begin);
    try self.tokens.end.append(end);
}

fn skipWhitespace(self: Tokenizer, current: *u32) void {
    while (true) {
        switch (self.source[current.*]) {
            ' ', '\r', '\t', '\n' => current.* += 1,
            else => return,
        }       
    }
}

pub fn lex(self: *Tokenizer) !void {
    var tag: Tag = .invalid;
    var start: u32 = 0;
    var current: u32 = 0;

    // skip white space
    while (current < self.source.len) : (current += 1) {
        self.skipWhitespace(&current);
        start = current;
        switch (self.source[current]) {
            // is digit
            '0'...'9' => { 
                while (isDigit(self.source[current]) or self.source[current] == '.') 
                    current += 1;
                tag = .intLiteral;
            },
            '+' => tag = .plus,
            '-' => tag = .minus,
            '*' => tag = .star,
            '/' => tag = .slash,
            else => std.debug.print("{c}", .{self.source[current]}),
        }

        try self.appendToken(tag, start, current);
    }
}

pub const Tag = enum(u8) {
    invalid,
    eof,
    intLiteral,
    plus,
    minus,
    star,
    slash,
};

pub const Tokens = struct {
    pub const TagList = ArrayList(Tag);
    pub const U32List = ArrayList(u32);

    len: u32,
    tags: TagList,
    begin: U32List,
    end: U32List,


    pub fn debugPrint(self: Tokens) void {
        const print = std.debug.print;
        var i: u32 = 0;
        while (i < self.len) : (i += 1) {
            print("(Tag: {?}) ", .{self.tags.items[i]});
            if (@mod(i+1, 2) == 0) 
                print("\n", .{});
        }

    }
};

