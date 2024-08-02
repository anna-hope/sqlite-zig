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

// pub const Statement = union(StatementTypeTag) {
//     insert: InsertStement,
//     select: void,

//     const Self = @This();

// };

pub const StatementParseError = error{
    Unrecognized,
    Syntax,
};

pub const Statement = union(StatementTypeTag) {
    insert: InsertStement,
    select: void,

    const Self = @This();

    pub fn parse(buf: []u8) !Self {
        if (std.mem.startsWith(u8, buf, "insert")) {
            var tokens = std.mem.splitScalar(u8, buf, ' ');

            const maybe_keyword = tokens.next();
            if (maybe_keyword) |keyword| {
                if (!std.mem.eql(u8, keyword, "insert")) {
                    return error.Unrecognized;
                }
            }

            const row_id = try blk: {
                const maybe_row_id_buf = tokens.next();
                if (maybe_row_id_buf) |row_id_buf| {
                    break :blk std.fmt.parseInt(u32, row_id_buf, 10);
                }
                return StatementParseError.Syntax;
            };

            var username: [username_size]u8 = undefined;
            if (tokens.next()) |username_buf| {
                std.mem.copyBackwards(u8, &username, username_buf);
            } else {
                return error.Syntax;
            }

            var email: [email_size]u8 = undefined;
            if (tokens.next()) |email_buf| {
                std.mem.copyBackwards(u8, &email, email_buf);
            } else {
                return error.Syntax;
            }

            const insert = InsertStement{ .row = Row{ .id = row_id, .username = username, .email = email } };

            return Self{ .insert = insert };
        } else if (std.mem.startsWith(u8, buf, "select")) {
            return Self{ .select = undefined };
        }

        return error.Unrecognized;
    }
};
