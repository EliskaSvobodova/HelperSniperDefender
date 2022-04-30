fn do_random(w, memory) {
	let r = (rand() % 4).abs();
	switch r {
	    0 => worker(w).move_up(),
	    1 => worker(w).move_down(),
	    2 => worker(w).move_right(),
	    3 => worker(w).move_left(),
	}
	if memory.jobs[w] == [worker(w).x, worker(w).y] {
		memory.jobs[w] = 0;
	}
	return memory;
}


fn go_to(w, x, y, memory, map) {
	if memory.jobs[w] == [worker(w).x, worker(w).y] {
		memory.jobs[w] = 0;
		return memory;
	}
	let tasks = [];
	if x < worker(w).x {
	    tasks.push(3);
	    if map[worker(w).x-1][worker(w).y] != worker(w).color {
	    	tasks.push(3);
	    	tasks.push(3);
	    }
	}
	if x > worker(w).x {
		tasks.push(2);
		if map[worker(w).x+1][worker(w).y] != worker(w).color {
	    	tasks.push(2);
	    	tasks.push(2);
	    }
	}
	if y < worker(w).y {
		tasks.push(1);
		if map[worker(w).x][worker(w).y-1] != worker(w).color {
	    	tasks.push(1);
	    	tasks.push(1);
	    }
	}
	if y > worker(w).y {
		tasks.push(0);
		if map[worker(w).x][worker(w).y+1] != worker(w).color {
	    	tasks.push(0);
	    	tasks.push(0);
	    }
	}
	switch tasks[rand() % tasks.len] {
        0 => worker(w).move_up(),
        1 => worker(w).move_down(),
        2 => worker(w).move_right(),
        3 => worker(w).move_left(),
    }
	if memory.jobs[w] == [worker(w).x, worker(w).y] {
		memory.jobs[w] = 0;
	}
	return memory;
}


fn my_cluster_map(w, map) {
	let bfs_map = [];
	let clm = [];
	for i in 0..40 {
		bfs_map.push([]);
		clm.push([]);
		for j in 0..40 {
			bfs_map[i].push(0);
			clm[i].push(0);
		}
	}
	let clusters = [];

	for y in 0..40 {
		for x in 0..40 {
			if bfs_map[x][y] != 0 || map[x][y] != worker(w).color {
				continue;
			}
			clusters.push(0);
			let q = [[x, y]];
			bfs_map[x][y] = 1;
			while q.len != 0 {
				let tile = q.get(0);
				q.chop(q.len - 1);
				if tile[0] > 0 && bfs_map[tile[0] - 1][tile[1]] == 0 && map[tile[0] - 1][tile[1]] == worker(w).color {
					clm[tile[0] - 1][tile[1]] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0] - 1][tile[1]] = 1;
					q.push([tile[0] - 1, tile[1]]);
				}
				if tile[0] < 40-1 && bfs_map[tile[0] + 1][tile[1]] == 0 && map[tile[0] + 1][tile[1]] == worker(w).color {
					clm[tile[0] + 1][tile[1]] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0] + 1][tile[1]] = 1;
					q.push([tile[0] + 1, tile[1]]);
				}
				if tile[1] > 0 && bfs_map[tile[0]][tile[1] - 1] == 0 && map[tile[0]][tile[1] - 1] == worker(w).color {
					clm[tile[0]][tile[1] - 1] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0]][tile[1] - 1] = 1;
					q.push([tile[0], tile[1] - 1]);
				}
				if tile[1] < 40-1 && bfs_map[tile[0]][tile[1] + 1] == 0 && map[tile[0]][tile[1] + 1] == worker(w).color {
					clm[tile[0]][tile[1] + 1] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0]][tile[1] + 1] = 1;
					q.push([tile[0], tile[1] + 1]);
				}
				bfs_map[tile[0]][tile[1]] = 2;
			}
		}
	}

	return [clm, clusters];
}



fn cluster_map(w, map) {
	let bfs_map = [];
	let clm = [];
	for i in 0..40 {
		bfs_map.push([]);
		clm.push([]);
		for j in 0..40 {
			bfs_map[i].push(0);
			clm[i].push(0);
		}
	}
	let clusters = [];

	for y in 0..40 {
		for x in 0..40 {
			if bfs_map[x][y] != 0 || map[x][y] == worker(w).color || map[x][y] == Tile::EMPTY {
				continue;
			}
			clusters.push(0);
			let q = [[x, y]];
			bfs_map[x][y] = 1;
			while q.len != 0 {
				let tile = q.get(0);
				q.chop(q.len - 1);
				if tile[0] > 0 && bfs_map[tile[0] - 1][tile[1]] == 0 && map[tile[0] - 1][tile[1]] == map[x][y] {
					clm[tile[0] - 1][tile[1]] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0] - 1][tile[1]] = 1;
					q.push([tile[0] - 1, tile[1]]);
				}
				if tile[0] < 40-1 && bfs_map[tile[0] + 1][tile[1]] == 0 && map[tile[0] + 1][tile[1]] == map[x][y] {
					clm[tile[0] + 1][tile[1]] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0] + 1][tile[1]] = 1;
					q.push([tile[0] + 1, tile[1]]);
				}
				if tile[1] > 0 && bfs_map[tile[0]][tile[1] - 1] == 0 && map[tile[0]][tile[1] - 1] == map[x][y] {
					clm[tile[0]][tile[1] - 1] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0]][tile[1] - 1] = 1;
					q.push([tile[0], tile[1] - 1]);
				}
				if tile[1] < 40-1 && bfs_map[tile[0]][tile[1] + 1] == 0 && map[tile[0]][tile[1] + 1] == map[x][y] {
					clm[tile[0]][tile[1] + 1] = clusters.len;
					clusters[-1] += 1;
					bfs_map[tile[0]][tile[1] + 1] = 1;
					q.push([tile[0], tile[1] + 1]);
				}
				bfs_map[tile[0]][tile[1]] = 2;
			}
		}
	}

	return [clm, clusters];
}



fn biggest_cluster_center(w, map, clm, totals) {
	let max_cl = 0;
	for cl in range(0, totals.len) {
		if totals[cl] > totals[max_cl] {
			max_cl = cl;
		}
	}
	let min_x = 40;
	let max_x = 0;
	let min_y = 40;
	let max_y = 0;
	for y in 0..40 {
		for x in 0..40 {
			if clm[x][y] == max_cl+1 {
				if x < min_x {
					min_x = x;
				}
				if x > max_x {
					max_x = x;
				}
				if y < min_y {
					min_y = y;
				}
				if y > max_y {
					max_y = y;
				}
			}
		}
	}
	return [min_x + ((max_x - min_x) / 2), min_y + ((max_y - min_y) / 2)];
}


fn closest_wall(w) {
	if worker(w).x < 20 {  // left
		if worker(w).y < 20 {  // down
			if worker(w).x < worker(w).y {
				return [0, worker(w).y];
			} else {
				return [worker(w).x, 0];
			}
		} else {  // up
			if worker(w).x < (39 - worker(w).y) {
				return [0, worker(w).y];
			} else {
				return [worker(w).x, 39];
			}
		}
	} else {  // right
		if worker(w).y < 20 {  // down
			if (39 - worker(w).x) < worker(w).y {
				return [39, worker(w).y];
			} else {
				return [worker(w).x, 0];
			}
		} else {  // up
			if (39 - worker(w).x) < (39 - worker(w).y) {
				return [39, worker(w).y];
			} else {
				return [worker(w).x, 39];
			}
		}
	}
}


fn tile_not_taken(memory, tile) {
	for i in 0..8 {
		if memory.jobs[i] == tile {
			return false;
		}
	}
	return true;
}


fn closest_enemy(w, map, memory, start_x, start_y) {
	let bfs_map = [];
	for i in 0..40 {
		bfs_map.push([]);
		for j in 0..40 {
			bfs_map[i].push(0);
		}
	}
	let q = [[start_x, start_y]];
	bfs_map[q[0][0]][q[0][1]] = 1;
	while q.len != 0 {
		let tile = q.get(0);
		q.chop(q.len - 1);
		let directions = [0, 1, 2, 3];
		while directions.len != 0 {
			let r = rand() % directions.len;
			if directions[r] == 0 {
				if tile[0] > 0 && bfs_map[tile[0] - 1][tile[1]] == 0 {
					if map[tile[0] - 1][tile[1]] != worker(w).color && tile_not_taken(memory, [tile[0] - 1, tile[1]]) {
						return [tile[0] - 1, tile[1]];
					}
					bfs_map[tile[0] - 1][tile[1]] = 1;
					q.push([tile[0] - 1, tile[1]]);
				}
				directions.remove(r);
			} else if directions[r] == 1 {
				if tile[0] < 40-1 && bfs_map[tile[0] + 1][tile[1]] == 0 {
					if map[tile[0] + 1][tile[1]] != worker(w).color && tile_not_taken(memory, [tile[0] + 1, tile[1]]) {
						return [tile[0] + 1, tile[1]];
					}
					bfs_map[tile[0] + 1][tile[1]] = 1;
					q.push([tile[0] + 1, tile[1]]);
				}
				directions.remove(r);
			} else if directions[r] == 2 {
				if tile[1] > 0 && bfs_map[tile[0]][tile[1] - 1] == 0 {
					if map[tile[0]][tile[1] - 1] != worker(w).color && tile_not_taken(memory, [tile[0], tile[1] - 1]) {
						return [tile[0], tile[1] - 1];
					}
					bfs_map[tile[0]][tile[1] - 1] = 1;
					q.push([tile[0], tile[1] - 1]);
				}
				directions.remove(r);
			} else {
				if tile[1] < 40-1 && bfs_map[tile[0]][tile[1] + 1] == 0 {
					if map[tile[0]][tile[1] + 1] != worker(w).color && tile_not_taken(memory, [tile[0], tile[1] + 1]) {
						return [tile[0], tile[1] + 1];
					}
					bfs_map[tile[0]][tile[1] + 1] = 1;
					q.push([tile[0], tile[1] + 1]);
				}
				directions.remove(r);
			}
		}
		bfs_map[tile[0]][tile[1]] = 2;
	}
	return []
}


fn helper(w, map, memory) {
	if memory.jobs[w] == 0 || worker(w).x == 0 || worker(w).x == 39 || worker(w).y == 0 || worker(w).y == 39 {
		let res = cluster_map(w, map);
		let clm = res[0];
		let totals = res[1];
		let target = biggest_cluster_center(w, map, clm, totals);
		memory.jobs[w] = [target[0] - worker(w).x, target[1] - worker(w).y]
	}
	if rand() % (memory.jobs[w][0].abs() + memory.jobs[w][1].abs()) < memory.jobs[w][0].abs() {
		if memory.jobs[w][0] < 0 {
			worker(w).move_left();
		} else {
			worker(w).move_right();
		}
	} else {
		if memory.jobs[w][1] < 0 {
			worker(w).move_down();
		} else {
			worker(w).move_up();
		}
	}
	
	return memory;
}


fn colorer(w, map, memory) {
	if memory.jobs[w] == 0 {
		let closest = closest_enemy(w, map, memory, worker(w).x, worker(w).y);
		if closest == [] {
			memory = do_random(w, memory);
		} else {
			memory.jobs[w] = closest;
			memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory, map);
		}
	} else {
		if rand() % 7 == 0 {
			memory = do_random(w, memory);
		} else {
			memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory, map);
		}
	}

	return memory;
}


fn cluster_colorer(w, map, memory) {
	if memory.jobs[w] == 0 {
		info("assign");
		let res = my_cluster_map(w, map);
		let clm = res[0];
		let totals = res[1];
		let my_cluster_center = biggest_cluster_center(w, map, clm, totals);
		memory.jobs[w] = closest_enemy(w, map, memory, my_cluster_center[0], my_cluster_center[1]);
		info(`${memory.jobs[w]}`);
		memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory, map);
	} else {
		info("go");
		if rand() % 7 == 0 {
			memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory, map);
		} else {
			memory = do_random(w, memory);
		}
	}
	return memory;
}



fn move_idx(w, idx) {
	switch idx {
        0 => worker(w).move_up(),
        1 => worker(w).move_down(),
        2 => worker(w).move_right(),
        3 => worker(w).move_left(),
    }
}


fn by_wall(w, d) {
	if (worker(w).x == 0 && d == 3) || (worker(w).x == 39 && d == 2) || (worker(w).y == 39 && d == 0) || (worker(w).y == 0 && d == 1) {
		return true;
	}
	return false;
}



fn sniper(w, map, memory) {
	if memory.tick == 0 {
		let d = [];
		if map[worker(w).x-1][worker(w).y] == Tile::EMPTY {
			d.push(3);
		}
		if map[worker(w).x+1][worker(w).y] == Tile::EMPTY {
			d.push(2);
		}
		if map[worker(w).x][worker(w).y-1] == Tile::EMPTY {
			d.push(1);
		}
		if map[worker(w).x][worker(w).y+1] == Tile::EMPTY {
			d.push(0);
		}
		let r = d[rand() % d.len];
		memory.jobs[w] = r;
		move_idx(w, r);
	} else {
		if by_wall(w, memory.jobs[w]) || rand() % 30 == 0 {
			let d = [0, 1, 2, 3];
			d.remove(memory.jobs[w]);
			let r = d[rand() % d.len];
			memory.jobs[w] = r;
			move_idx(w, r);
		} else {
			move_idx(w, memory.jobs[w]);
		}
	}
	return memory;
}


if ("tick" in memory) == false {
	memory.tick = 0;
	memory.roles = [0, 0, 0, 0, 0, 0, 0, 0];
	memory.jobs = [0, 0, 0, 0, 0, 0, 0, 0];
	info(`Color: ${worker(0).color}`);
}

if memory.tick < 10 {
	for w in 0..2 {
		memory = helper(w, map, memory);
	}
	memory = sniper(2, map, memory);
	for w in 3..8 {
		memory = do_random(w, memory);
	}
} else {
	for w in 0..2 {
		memory = helper(w, map, memory);
	}
	memory = sniper(2, map, memory);
	for w in 3..8 {
		memory = cluster_colorer(w, map, memory);
	}
}


memory.tick += 1;