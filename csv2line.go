package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	// input file
	fh, err := os.Open("perf.csv")
	if err != nil {
		log.Fatal(err)
	}
	defer fh.Close()

	// csv read
	reader := csv.NewReader(fp)
	reader.LazyQuotes = true
	rows, err := reader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}

}
