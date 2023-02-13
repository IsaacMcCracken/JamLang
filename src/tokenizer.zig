
const Tokenizer = @This();

const std = @import("std");
const ArrayList = std.ArrayList;

pub const Tag = enum(u8) {
    invalid,
    intLiteral,
    plus,
    minus,
    star,
    slash,
};

pub const Token = struct {
    pub const TagList = ArrayList(Tag);
    pub const U32List = ArrayList(u32);

    
};

source: []u8,
