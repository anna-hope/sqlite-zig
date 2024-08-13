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

pub const PagesRowsIterator = struct {
    page_index: usize = 0,
    row_index: usize = 0,
    pages: []const Page,
    reached_max_rows: bool = false,

    pub fn next(self: *PagesRowsIterator) ?Row {
        // We're past the last page
        if (self.reached_max_rows or self.page_index == self.pages.len) {
            return null;
        }

        const page = self.pages[self.page_index];

        // We're past the last row of the last page
        if (self.row_index == page.rows.len) {
            return null;
        }

        const row = page.rows.get(self.row_index);

        // Do we still have rows left in this page?
        if (self.row_index + 1 < page.rows.len) {
            self.row_index += 1;
        } else if (self.row_index + 1 == page.rows.len and self.page_index + 1 < self.pages.len) {
            // Check if we need to move on to the next page
            // This happens if the row index reached the maximum number of rows in this page
            // but we have more pages left
            self.row_index = 0;
            self.page_index += 1;
        } else {
            self.reached_max_rows = true;
        }

        return row;
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

    pub fn allRows(self: Self) PagesRowsIterator {
        return PagesRowsIterator{ .pages = self.pages.slice() };
    }
};
