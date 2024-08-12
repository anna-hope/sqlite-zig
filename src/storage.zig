const std = @import("std");

const max_pages_table = 100;

// TODO: this isn't really the way to do this
const max_rows_per_page = 30;

const username_size = 32;
const email_size = 255;

pub const username_alias = [username_size]u8;
pub const email_alias = [email_size]u8;

pub const Row = struct {
    id: u32,
    username: username_alias,
    email: email_alias,
};

const Page = struct {
    const Self = @This();
    rows: std.BoundedArray(Row, max_rows_per_page),

    fn init() !Page {
        return Page{ .rows = try std.BoundedArray(Row, max_rows_per_page).init(0) };
    }

    fn size(self: Self) usize {
        return self.rows.len;
    }
};

pub const Table = struct {
    const Self = @This();
    pages: std.BoundedArray(Page, max_pages_table),
    current_page: *Page,

    pub fn init() !Self {
        var pages = try std.BoundedArray(Page, max_pages_table).init(0);
        const current_page = try pages.addOne();
        return Self{ .pages = pages, .current_page = current_page };
    }

    pub fn insertRow(self: *Self, row: Row) !void {
        if (self.current_page.size() == self.current_page.rows.capacity()) {
            self.current_page = try self.pages.addOne();
        }

        try self.current_page.rows.append(row);
    }
};
