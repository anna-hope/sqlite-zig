const std = @import("std");

const page_size = 4096;
const table_max_pages = 100;

const rows_per_page = page_size / @sizeOf(Row);
const table_max_rows = rows_per_page * table_max_pages;

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
    rows: std.BoundedArray(Row, rows_per_page),

    fn init() !Page {
        return Page{ .rows = try std.BoundedArray(Row, rows_per_page).init(0) };
    }

    fn size(self: Self) usize {
        return self.rows.len;
    }
};

pub const Table = struct {
    const Self = @This();
    pages: std.BoundedArray(Page, table_max_pages),
    current_page: *Page,

    pub fn init() !Self {
        var pages = try std.BoundedArray(Page, table_max_pages).init(0);
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
