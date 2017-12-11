package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type ticker struct {
	BtcRur curr `json:"btc_rur"`
}

type curr struct {
	Buy  float64 `json:"buy"`
	Sell float64 `json:"sell"`
}

const btcAmount = 0.03297001
const initialAmount = 24900
const internalIncreased = 1500
const withdrawed = 1664

func main() {
	var t ticker
	resp, err := http.Get("https://wex.nz/api/3/ticker/btc_rur")
	if err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}
	err = json.Unmarshal(body, &t)
	if err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}

	btc := t.BtcRur.Sell * btcAmount
	earned := btc - initialAmount + withdrawed

	fmt.Printf("%d %d %d", int(btc), int(earned), int((earned)/2-withdrawed-internalIncreased))
}
