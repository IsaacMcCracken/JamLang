const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

pub fn CircularQueue(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T,
        allocator: Allocator,
        front: usize,
        size: usize,

        pub fn init(allocator: Allocator, capacity: usize) !Self {
            var result = Self {
                .items = &[_]T{},
                .allocator = allocator,
                .front = 0,
                .size = 0,
            };
            result.items = try result.allocator.alloc(T, capacity);
            return result; 
        }

        pub fn enqueue(self: *Self, item: T) void {
            const index = @mod(self.size, self.items.len);
            self.size += 1;
            self.items[index] = item;   
        }

        pub fn dequeue(self: *Self) T {
            const result = self.items[self.front];
            self.front = @mod(self.front + 1, self.items.len);
            self.size -= 1;
            return result;
        }

        pub fn printQueue(self: Self) void {
            print("\n<<", .{});
            var i: usize = 0; 
            var index: usize = undefined;
            while (i < self.size) : (i += 1) {
                index = @mod(self.front + i, self.items.len);
                print(" {}", .{self.items[index]});
            }
            print(" >>\n", .{});
        }

    };
}

test "enqueue" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const NumberQueue = CircularQueue(u32);
    var queue = try NumberQueue.init(allocator, 4);

    queue.enqueue(69);
    queue.enqueue(420);
    queue.enqueue(22);
    queue.enqueue(32);

    queue.printQueue();

    _ = queue.dequeue();
    _ = queue.dequeue();

    queue.printQueue();
    queue.enqueue(554);
    queue.printQueue();
    
}