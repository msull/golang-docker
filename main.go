package main

import (
	"fmt"
	"net/http"
	"time"
)

func checkWebsite(website string) error {

	parisTz, _ := time.LoadLocation("Europe/Paris")
	pacificTz, _ := time.LoadLocation("America/Los_Angeles")
	now := time.Now()
	parisTime := now.In(parisTz)
	pacificTime := now.In(pacificTz)

	resp, err := http.Get(website)
	if err != nil {
		return err
	}

	if resp.StatusCode >= 200 && resp.StatusCode <= 299 {
		fmt.Println("Website :", website, "is Up", "HTTP Response Status:", resp.StatusCode, http.StatusText(resp.StatusCode))
	} else {
		fmt.Println("Website :", website, " Broken", "HTTP Response Status:", resp.StatusCode, http.StatusText(resp.StatusCode))
	}
	fmt.Println("Paris is magic : what time is it in Paris ?", parisTime)
	fmt.Println("West coast is best coast : what time is it in LA ?", pacificTime)

	return err
}

func main() {
	checkWebsite("https://google.com")
}
