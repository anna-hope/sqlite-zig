const std = @import("std");
const Allocator = std.mem.Allocator;

const username_size = 32;
const email_size = 255;

pub const MetaCommandError = error{
    Unrecognized,
};

pub fn processMetaCommand(_: []u8) MetaCommandError!void {
    return error.Unrecognized;
}

pub const Row = struct {
    id: u32,
    username: [username_size]u8,
    email: [email_size]u8,
};

pub const InsertStement = struct {
    row: Row,
};

pub const StatementTypeTag = enum {
    insert,
    select,
};

pub const StatementType = union(StatementTypeTag) {
    insert: InsertStement,
    select: void,
};

pub const StatementParseError = error{
    Unrecognized,
    Invalid,
};

pub const Statement = struct {
    const Self = @This();
    statement_type: StatementType,

    pub fn parse(buf: []u8, allocator: Allocator) StatementParseError!Self {
        if (std.mem.startsWith(u8, buf, "insert")) {
            const tokens = std.mem.splitScalar(u8, buf, ' ');
            const maybe_keyword = tokens.next();
            if (maybe_keyword) |keyword| {
                if (!std.mem.eql(u8, keyword, "insert")) {
                    return error.Invalid;
                }
            }

            const row_id: u32 = undefined;
            const username = try allocator.alloc(u8, 32);
            const email = try allocator.alloc(u8, 255);

            return Self{ .statement_type = .insert };
        } else if (std.mem.startsWith(u8, buf, "select")) {
            return Self{ .statement_type = .select };
        }

        return error.Unrecognized;
    }
};
