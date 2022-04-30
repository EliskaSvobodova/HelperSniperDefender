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


fn go_to(w, x, y, memory) {
	if memory.jobs[w] == [worker(w).x, worker(w).y] {
		memory.jobs[w] = 0;
		return memory;
	}
	let tasks = [];
	if x < worker(w).x {
	    tasks.push(3);
	}
	if x > worker(w).x {
		tasks.push(2);
	}
	if y < worker(w).y {
		tasks.push(1);
	}
	if y > worker(w).y {
		tasks.push(0);
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



fn enemy_cluster_center(w, map) {
	let res = cluster_map(w, map);
	let clm = res[0];
	let totals = res[1];
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


fn helper(w, map, memory) {
	if memory.jobs[w] == 0 {
		if worker(w).x == 0 || worker(w).x == 39 || worker(w).y == 0 || worker(w).y == 39 {
			memory.jobs[w] = enemy_cluster_center(w, map);
			info(`cluster ${memory.jobs[w]}`);
		} else {
			memory.jobs[w] = closest_wall(w);
			info(`wall ${memory.jobs[w]}`);
		}
		memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory);
	} else {
		if rand() % 2 == 0 {
			memory = go_to(w, memory.jobs[w][0], memory.jobs[w][1], memory);
		} else {
			memory = do_random(w, memory);
		}
	}
	return memory
}



if ("tick" in memory) == false {
	memory.tick = 0;
	memory.roles = [0, 0, 0, 0, 0, 0, 0, 0];
	memory.jobs = [0, 0, 0, 0, 0, 0, 0, 0];
	info(`Color: ${worker(0).color}`);
}


for w in 0..8 {
	memory = helper(w, map, memory);
}

