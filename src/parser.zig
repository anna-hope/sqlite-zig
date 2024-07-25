const std = @import("std");

pub const MetaCommandError = error{
    Unrecognized,
};

pub fn processMetaCommand(_: []u8) MetaCommandError!void {
    return error.Unrecognized;
}

pub const StatementType = enum {
    insert,
    select,
};

pub const StatementParseError = error{
    Unrecognized,
};

pub const Statement = struct {
    const Self = @This();
    statement_type: StatementType,

    pub fn parse(buf: []u8) StatementParseError!Self {
        if (std.mem.startsWith(u8, buf, "insert")) {
            return Self{ .statement_type = .insert };
        } else if (std.mem.startsWith(u8, buf, "select")) {
            return Self{ .statement_type = .select };
        }

        return error.Unrecognized;
    }
};
