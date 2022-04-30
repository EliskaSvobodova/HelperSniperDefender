fn do_random(w) {
	let r = (rand() % 4).abs();
	switch r {
	    0 => worker(w).move_up(),
	    1 => worker(w).move_down(),
	    2 => worker(w).move_right(),
	    3 => worker(w).move_left(),
	}
}


fn closest_enemy(w, map) {
	let first = true;
	let x;
	let y;
	let dist;
	let other_dist;
	for x_m in 0..40 {
		for y_m in 0..40 {
			if map[x_m][y_m] != worker(w).color {
				if first {
	                first = false;
	                x = x_m;
	                y = y_m;
	                dist = (x_m - worker(w).x).abs() + (y_m - worker(w).y).abs();
	            } else {
	                other_dist = (x_m - worker(w).x).abs() + (y_m - worker(w).y).abs();
	                if other_dist < dist {
	                    dist = other_dist;
	                    x = x_m;
	                    y = y_m;
	                }
	            }
			}
		}
	}

	return [x, y]
}


fn worker_corner(wk) {
	/* [is_left, is_down] */
	let c = [];
	if wk.x < 20 {  // left
		c.push(0);
	} else {  // right
		c.push(1);
	}
	if wk.y < 20 {  // down
		c.push(0);
	} else {  // up
		c.push(1);
	}
	return c
}

fn tile_not_taken(memory, tile) {
	for i in 0..8 {
		if memory.jobs[i] == tile {
			return false;
		}
	}
	return true;
}


fn corner_closest_enemy(w, map, memory) {
	let bfs_map = [];
	for i in 0..40 {
		bfs_map.push([]);
		for j in 0..40 {
			bfs_map[i].push(0);
		}
	}
	let first_x = memory.corner[0];
	if first_x == 1 {
		first_x = 39;
	}
	let first_y = memory.corner[1];
	if first_y == 1 {
		first_y = 39;
	}
	let q = [[first_x, first_y]];
	bfs_map[q[0][0]][q[0][1]] = 1;
	while q.len != 0 {
		let tile = q.get(0);
		q.chop(q.len - 1);
		if tile[0] > 0 && bfs_map[tile[0] - 1][tile[1]] == 0 {
			if map[tile[0] - 1][tile[1]] != worker(w).color && tile_not_taken(memory, [tile[0] - 1, tile[1]]) {
				return [tile[0] - 1, tile[1]];
			}
			bfs_map[tile[0] - 1][tile[1]] = 1;
			q.push([tile[0] - 1, tile[1]]);
		}
		if tile[0] < 40-1 && bfs_map[tile[0] + 1][tile[1]] == 0 {
			if map[tile[0] + 1][tile[1]] != worker(w).color && tile_not_taken(memory, [tile[0] + 1, tile[1]]) {
				return [tile[0] + 1, tile[1]];
			}
			bfs_map[tile[0] + 1][tile[1]] = 1;
			q.push([tile[0] + 1, tile[1]]);
		}
		if tile[1] > 0 && bfs_map[tile[0]][tile[1] - 1] == 0 {
			if map[tile[0]][tile[1] - 1] != worker(w).color && tile_not_taken(memory, [tile[0], tile[1] - 1]) {
				return [tile[0], tile[1] - 1];
			}
			bfs_map[tile[0]][tile[1] - 1] = 1;
			q.push([tile[0], tile[1] - 1]);
		}
		if tile[1] < 40-1 && bfs_map[tile[0]][tile[1] + 1] == 0 {
			if map[tile[0]][tile[1] + 1] != worker(w).color && tile_not_taken(memory, [tile[0], tile[1] + 1]) {
				return [tile[0], tile[1] + 1];
			}
			bfs_map[tile[0]][tile[1] + 1] = 1;
			q.push([tile[0], tile[1] + 1]);
		}
		bfs_map[tile[0]][tile[1]] = 2;
	}
	return []
}


fn go_to(w, x, y, memory) {
	if x < worker(w).x {
	    worker(w).move_left();
	} else if x > worker(w).x {
		worker(w).move_right();
	} else if y < worker(w).y {
		worker(w).move_down();
	} else {
		worker(w).move_up();
	}
	if memory.jobs[w] == [x, y] {
		memory.jobs[w] = 0;
	}
}


fn assign_new_goal(w, map, memory) {
	let c = corner_closest_enemy(w, map, memory);
	memory.jobs[w] = c;
	if c == [] {
		do_random(w);
	} else {
		go_to(w, c[0], c[1], memory);
	}
	info(`${w}: new goal ${c}`);
}



// ------------------------------------------------------------------------------------
if ("tick" in memory) == false {
	memory.tick = 0;
	memory.corner = worker_corner(worker(0));
	memory.jobs = [0, 0, 0, 0, 0, 0, 0, 0];
	info(`Color: ${worker(0).color}`);
}
if memory.tick < 20 {
	let w = 0;
	if memory.jobs[w] == 0 {
		assign_new_goal(w, map, memory);
	} else {
		go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory);
		info(`initial 0: going to goal ${memory.jobs[w]}`);
	}
	for w in 1..8 {
		do_random(w);
	}
} else {
	for w in 0..8 {
		if rand() % 2 == 0 {
			info(`${w}: random`);
			do_random(w);
		} else if memory.jobs[w] == 0 {
			assign_new_goal(w, map, memory);
		} else {
			go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory);
			info(`${w}: going to goal ${memory.jobs[w]}`);
		}
	}
}
memory.tick += 1;
