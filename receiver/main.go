package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/Scalingo/go-workers"
)

func main() {

	http.HandleFunc("/", HelloHandler)
	fmt.Println("Server at port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))

	workers.Configure(map[string]string{
		"process": "client1",
		"server":  "redis:6379",
	})
	workers.Enqueue("default", "UpdateWorker", []string{"[\"hello\"]"})
}

func HelloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, there\n")
}

// package main

// import (
//     "encoding/json"
// "github.com/Scalingo/go-workers"
//     "log"
//     "net/http"
//     "io/ioutil"
// )

// type test_struct struct {
//     Test string
// }

// func test(rw http.ResponseWriter, req *http.Request) {
//     body, err := ioutil.ReadAll(req.Body)
//     if err != nil {
//         panic(err)
//     }
//     log.Println(string(body))
//     var t test_struct
//     err = json.Unmarshal(body, &t)
//     if err != nil {
//         panic(err)
//     }
//     log.Println(t.Test)
// }

// func main() {
// 	workers.Configure(map[string]string{
// 		"process": "client1",
// 		"server":  "localhost:6379",
// 	})
// 	workers.Enqueue("myqueue", "MyRubyWorker", []string{"hello"})

// 	http.HandleFunc("/test", test)
//     log.Fatal(http.ListenAndServe(":8082", nil))
// }
