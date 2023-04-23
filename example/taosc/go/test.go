package main

import (
	"database/sql"
	"fmt"
	"time"

	_ "github.com/taosdata/driver-go/v2/taosSql"
)

func main() {
	var taosDSN = "root:taosdata@tcp(localhost:6030)/"
	taos, err := sql.Open("taosSql", taosDSN)
	if err != nil {
		fmt.Println("failed to connect TDengine, err:", err)
		return
	}
	defer taos.Close()

	num := 1
	for num > 0 {
		fmt.Println("times   num:", num)
		rows, err := taos.Query("SELECT ts, current FROM db01.meters LIMITi 2")
		defer rows.Close()
		if err == nil {
			for rows.Next() {
				var r struct {
					ts      time.Time
					current float32
				}
				err := rows.Scan(&r.ts, &r.current)
				if err != nil {
					fmt.Println("scan error:\n", err)
					return
				}
				fmt.Println(r.ts, r.current)
			}
		} else {
			fmt.Println("failed to select from table, err:", err)
		}
		num++
	}
}
