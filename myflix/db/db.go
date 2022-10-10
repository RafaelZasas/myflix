package db

import (
	"encoding/json"
	"errors"
	"fmt"
	"os/exec"
	"time"

	"github.com/meilisearch/meilisearch-go"
	"github.com/rafaelzasas/myflix/backend/models"
)

type Movie = models.Movie

var moviesIndex *meilisearch.Index
var showsIndex *meilisearch.Index

var client *meilisearch.Client
var host string
var port string

// Number of times to attempt serving up db
var maxRetries = 6
var Retries = 1

// Init Meilisearch creates the client service for interacting with the db.
//
// Requires an intended port and apiKey to configure Meilisearch with.
// This function will also ensure that a database is running, healthy and instantiate
// a new instance if is not.
func InitMeilisearch(h string, p string, apiKey string) (err error) {

	host = h
	port = p

	// interfacing with the meiliesearch db
	client = meilisearch.NewClient(meilisearch.ClientConfig{
		Host:   fmt.Sprintf("http://%v:%v", host, port),
		APIKey: apiKey,
	})

	// creating index (collection) references for movies and shows
	// If any index does not exist, one will be created as soon as a doc is added
	moviesIndex = client.Index("movies")
	showsIndex = client.Index("shows")

	// Assuming that the db is not initialized when program starts
	err = startServer()
	time.Sleep(time.Second / 100)

	// propogate err up to main which will exit the program
	if err != nil {
		return err
	}

	// at this point we assume the db started successfully
	// but something happened to cause a failed health check
	if err := testHealth(); err != nil {

		// start retries
		for Retries <= maxRetries {

			exec.Command("pkill", "meilisearch").Run()

			fmt.Printf("\nretrying database startup 🚑️\nattempt number %v\n", Retries)
			err = startServer()

			if err != nil {
				return errors.New("error initialzing database ⚰️\nplease verify host, port and api keys")
			}

			napTime := time.Second * time.Duration(Retries)
			time.Sleep(napTime)

			if err := testHealth(); err != nil {
				if Retries == maxRetries-1 {
					fmt.Printf("max retries reached\nquitting\n")

				} else {
					fmt.Printf("\ntrying again...\n\n")

				}
				Retries += 1
			} else {
				// database is alive and well
				return nil
			}

			if Retries >= maxRetries {
				return errors.New("error initialzing database 🪦\nplease verify host, port and api keys")
			}

		}

	}

	return nil
}

// testHealth validates that the database is running at the given url.
//
// It also runs a get request at `/health` to validate that the db is running without errors.
func testHealth() (err error) {
	fmt.Println("testing database health 🩺 ...")

	// db /health returns non 2xx level
	if !client.IsHealthy() {
		health, err := client.Health()
		if err != nil {
			fmt.Println(err)
		}
		return fmt.Errorf("database health check failed 💩\nstatus:%v", health)
	}

	fmt.Printf("connection is healthy 💖 \n")

	return nil
}

func startServer() (err error) {
	fmt.Println("starting meiliesearch database 🏗️ ...")

	// cmd := exec.Command("meilisearch", fmt.Sprintf("--http-addr %v:%v", host, port))
	cmd := exec.Command("./meilisearch")

	err = cmd.Start()

	if err != nil {
		fmt.Printf("error starting meilisearch db 💩\n%v\n", err)
		return err
	}

	fmt.Printf("server started successfully ✅ \nrunning on http://%v:%v\n\n", host, port)

	return nil

}

// AddDocumentToIndex adds a single entry to the given index
func AddDocumentToIndex(index string, data interface{}) (err error) {

	movie := data.(Movie)
	task, err := client.Index(index).AddDocuments(movie, movie.ImdbId)

	if err != nil {
		return err
	}

	fmt.Printf("Adding Movie to Meilie Search\nTask ID: %v\nstatus: %v\n", task.TaskUID, task.Status)

	return nil
}

// GetMovie gets a single document from the Meilisearch movies index.
//
// You can optionally pass a list of fields to be returned if youu need to
// narrow the scope of the request
func GetMovie(docId string, fields []string) (movie Movie, err error) {

	if fields != nil {
		err = moviesIndex.GetDocument(docId, &meilisearch.DocumentQuery{
			Fields: fields,
		}, &movie)
	} else {
		err = moviesIndex.GetDocument(docId, nil, &movie)
	}

	if err != nil {
		return
	}

	return
}

// GetMovies gets all the documents in the movies index.
//
// You can optionally:
//
// Limit the number of documents returned.
// Offset them by a given number.
// Provide a list of fields to be returned in each object
func GetMovies(limit int64, offset int64, fields []string) (movies []Movie, err error) {

	var res meilisearch.DocumentsResult

	err = moviesIndex.GetDocuments(&meilisearch.DocumentsQuery{
		Limit:  limit,
		Offset: offset,
		Fields: fields,
	}, &res)

	if err != nil {
		return nil, err
	}

	stuff, err := json.Marshal(res.Results)

	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(stuff, &movies)

	if err != nil {
		return nil, err
	}

	return
}

// GetMovies gets a list of movies from Meilisearch which match
// a given query string
func SearchMovies(searchQuery string, limit int64, sort []string) (movies []Movie, err error) {

	searchResponse, err := moviesIndex.Search(
		searchQuery,
		&meilisearch.SearchRequest{
			Limit: limit,
			Sort:  sort,
		})

	if err != nil {
		return nil, err
	}

	stuff, err := json.Marshal(searchResponse.Hits)

	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(stuff, &movies)

	if err != nil {
		return nil, err
	}

	return
}

// updateDocument updates a document in a given index by document ID (primary key)
//
// If there is no document for the given index, one will be created.
// This will only partially update the document if it exists. Any new fields in the incoming data
// will be added to the existing document.
func UpdateDocument(index string, documentData interface{}, primaryKey string) (err error) {

	_, err = client.Index(index).UpdateDocuments(documentData, primaryKey)

	if err != nil {
		return err
	}

	fmt.Printf("Updated document %v in %v index\n", primaryKey, index)
	return nil
}

// DeleteDocument removes a document from db by ImdbId
func DeleteDocument(index string, docId string) (err error) {
	_, err = client.Index(index).DeleteDocument(docId)
	if err != nil {
		return
	}
	return
}
