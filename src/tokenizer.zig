
const Tokenizer = @This();

const std = @import("std");
const ArrayList = std.ArrayList;

source: []u8,
tokens: Tokens,

pub fn openSourceFromFile(self: *Tokenizer) !void {
    
}

pub const Tag = enum(u8) {
    invalid,
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
};

