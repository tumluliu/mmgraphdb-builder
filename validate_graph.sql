SELECT from_id, to_id, COUNT(*) FROM edges GROUP BY from_id, to_id HAVING COUNT(*) > 1;
