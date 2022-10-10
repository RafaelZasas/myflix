package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math/rand"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/rafaelzasas/myflix/db"
	"github.com/rafaelzasas/myflix/models"
)

type Movie = models.Movie

// type Show = models.Show
// type episode = models.Episode

type successfulGetResponse struct {
	Result interface{} `json:"result"`
	Count  int64       `json:"count"`
}

/**
		__MOVIE_ROUTES__
**/

// createMovie is the handler function for PUT /movies.
// Requires a json body of Movie type and uploades to the db.
func createMovie(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Endpoint Hit: PUT /movies")

	reqBody, err := ioutil.ReadAll(r.Body)

	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading request body.e\n%v\n", err.Error()), http.StatusBadRequest)
	}

	var movie Movie
	json.Unmarshal(reqBody, &movie)

	err = db.AddDocumentToIndex("movies", movie)

	if err != nil {
		http.Error(w, fmt.Sprintf("Error uploading movie to database.\nv%v\n", err), http.StatusInternalServerError)
	}

	w.WriteHeader(http.StatusCreated)
}

// readAllMovies is the handler function for GET /movies.
//
// A json request body with limit, offset and fields can be provided.
//
// the fields request param must be a list of string fields which are to be returned to the client.
func readAllMovies(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Endpoint Hit: GET /movies")

	type postBody struct {
		Limit  int64    `json:"limit"`
		Fields []string `json:"fields"`
		Offset int64    `json:"offset"`
	}

	var pb postBody

	// Try to decode the request body into the struct. If there is an error,
	// respond to the client with the error message and a 400 status code.
	err := json.NewDecoder(r.Body).Decode(&pb)

	if err != nil && err.Error() != "EOF" {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	movies, err := db.GetMovies(pb.Limit, pb.Offset, pb.Fields)

	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting movies\n%v", err), http.StatusInternalServerError)
		return
	}

	resp := successfulGetResponse{
		Count:  int64(len(movies)),
		Result: movies,
	}

	// this will encode the movies list into a json format
	json.NewEncoder(w).Encode(resp)
}

// readMovie is the handler function for GET /movies/{id}.
//
// The id path param must be the movie's IMDB Id.
func readMovie(w http.ResponseWriter, r *http.Request) {

	fmt.Printf("Endpoint Hit: GET /movie/{id}")

	type postBody struct {
		Fields []string `json:"fields"`
	}

	var pb postBody

	// Try to decode the request body into the struct. If there is an error,
	// respond to the client with the error message and a 400 status code.
	err := json.NewDecoder(r.Body).Decode(&pb)

	if err != nil && err.Error() != "EOF" {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	vars := mux.Vars(r)

	movieId, ok := vars["id"]

	if !ok {
		http.Error(w, "Invalid movie Id", http.StatusBadRequest)
	}

	movie, err := db.GetMovie(movieId, pb.Fields)

	if err != nil {
		http.Error(w, "Movie Not Found", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(movie)
}

// updateMovie is the hanfler function for PUT /movies/{id}
func updateMovie(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: PUT /movies{id}")

	vars := mux.Vars(r)

	movieId, ok := vars["id"]

	if !ok {
		http.Error(w, "Invalid movie Id", http.StatusBadRequest)
	}

	reqBody, err := ioutil.ReadAll(r.Body)

	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading request body.e\n%v\n", err.Error()), http.StatusBadRequest)
	}

	var movie Movie
	json.Unmarshal(reqBody, &movie)

	// check if document exists
	movie, err = db.GetMovie(movieId, nil)

	if err != nil {
		http.Error(w, fmt.Sprintf("Movie with id %v does not exist", movie.ImdbId), http.StatusBadRequest)
	}

	err = db.UpdateDocument("movies", movie, movieId)

	if err != nil {
		http.Error(w, fmt.Sprintf("Error updating movie.\nv%v\n", err), http.StatusInternalServerError)
	}

	w.WriteHeader(http.StatusOK)
}

// updateMovie is the hanfler function for PATCH /movies/{id}
// func partialUpdateMovie(w http.ResponseWriter, r *http.Request) {
// 	fmt.Println("Endpoint Hit: PATCH /movies")

// }

// deleteMovie is the handler function for DELETE /movies/{id}
func deleteMovie(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: DELETE /movies")

	vars := mux.Vars(r)

	movieId, ok := vars["id"]

	if !ok {
		http.Error(w, "Invalid movie Id", http.StatusBadRequest)
	}

	err := db.DeleteDocument("movies", movieId)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	w.WriteHeader(http.StatusNoContent)

}

// TODO: ADD ROUTE HANDLERS UPDATE AND DELETE MOVIE ROUTES

/**
		__SHOW HANDLERS__
**/
// TODO: ADD ROUTE HANDLERS FOR SHOWS

/**
		__EPISODE HANDLERS__
**/
// TODO: ADD ROUTE HANDLERS FOR EPISODES

/**
		__SEARCH HANDLERS__
**/

// getMoviesBySearch is the handler function for GET /search/movies
// Requires a json request body with `queryString` property.
//
// Optional properties for limit and sort can be given.
func getMoviesBySearch(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Endpoint Hit: GET /search/movies")

	type postBody struct {
		QueryString string   `json:"queryString"`
		Limit       int64    `json:"limit"`
		Sort        []string `json:"sort"`
	}

	var pb postBody

	// Try to decode the request body into the struct. If there is an error,
	// respond to the client with the error message and a 400 status code.
	err := json.NewDecoder(r.Body).Decode(&pb)

	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	movies, err := db.SearchMovies(pb.QueryString, pb.Limit, pb.Sort)

	if err != nil {
		http.Error(w, "Could not find any matching movies...", http.StatusNotFound)
		return
	}
	json.NewEncoder(w).Encode(movies)
}

/**
		__MISC__
**/

// getReaturedContent retrieves featured (popular) content from the database
//
// TODO: Implement real logic for determining what should be featured
func getFeaturedContent(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Endpoint Hit: GET /content/featured")

	movies, err := db.GetMovies(100, 0, nil)

	n := len(movies)

	if len(movies) > 0 {
		n -= 1
	}

	randomIndex := rand.Intn(n)

	// Have to unwrap the string from redis into bytes then convert to json as a Movie obj

	if err != nil {
		http.Error(w, "Error getting featured content", 500)
	}

	json.NewEncoder(w).Encode(movies[randomIndex])
}

// commonMiddleware provides middleware to api all routes such as content type and headers
func commonMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Content-Type", "application/json")
		w.Header().Add("Access-Control-Allow-Origin", "*")
		next.ServeHTTP(w, r)
	})
}

// HanleRequests is the main controller for api route management
func handleRequests() {

	router := mux.NewRouter().StrictSlash(true)

	router.Use(commonMiddleware)

	//Movie Routes
	router.HandleFunc("/movies", createMovie).Methods(http.MethodPost)
	router.HandleFunc("/movies", readAllMovies).Methods(http.MethodGet)
	router.HandleFunc("/movies/{id}", readMovie).Methods(http.MethodGet)
	router.HandleFunc("/movies/{id}", updateMovie).Methods(http.MethodPut)
	// router.HandleFunc("/movies/{id}", partialUpdateMovie).Methods(http.MethodPatch)
	router.HandleFunc("/movies/{id}", deleteMovie).Methods(http.MethodDelete)

	//Show Routes
	// router.HandleFunc("/shows", createShow).Methods(http.MethodPost)
	// router.HandleFunc("/shows", readAllShows).Methods(http.MethodGet)
	// router.HandleFunc("/shows/{id}", readShow).Methods(http.MethodGet)
	// router.HandleFunc("/shows/{id}", updateShow).Methods(http.MethodPut)
	// router.HandleFunc("/shows/{id}", partialUpdateShow).Methods(http.MethodPatch)
	// router.HandleFunc("/shows/{id}", deleteShow).Methods(http.MethodDelete)

	//Season Routes
	// router.HandleFunc("/shows/{showId}/seasons", createSeasons).Methods(http.MethodPost)
	// router.HandleFunc("/shows/{showId}/seasons", readSeasons).Methods(http.MethodGet)
	// router.HandleFunc("/shows/{showId}/seasons", updateSeason).Methods(http.MethodPut)
	// router.HandleFunc("/shows/{showId}/seasons", partialUpdateSeason).Methods(http.MethodPatch)
	// router.HandleFunc("/shows/{showId}/seasons", deleteSeason).Methods(http.MethodDelete)

	//Episode Routes
	// router.HandleFunc("/shows/{showId}/seasons/{episode}", createEpisode).Methods(http.MethodPost)
	// router.HandleFunc("/shows/{showId}/seasons/{episode}", readEpisode).Methods(http.MethodGet)
	// router.HandleFunc("/shows/{showId}/seasons/{episode}", updateEpisode).Methods(http.MethodPut)
	// router.HandleFunc("/shows/{showId}/seasons/{episode}", partialUpdateEpisode).Methods(http.MethodPatch)
	// router.HandleFunc("/shows/{showId}/seasons/{episode}", deleteEpisode).Methods(http.MethodDelete)

	//Search Ruutes
	router.HandleFunc("/search/movies", getMoviesBySearch).Methods(http.MethodPost)
	// router.HandleFunc("/search/shows", getShowsBySearch).Methods(http.MethodGet)
	// router.HandleFunc("/search/shows/{showId}", getEpisodesBySearch).Methods(http.MethodGet)
	// router.HandleFunc("/search/shows/{showId}/seasons/{seasonId}", getepisodesInSeasonBySearch).Methods(http.MethodGet)

	router.HandleFunc("/content/featured", getFeaturedContent).Methods(http.MethodGet)


	fmt.Printf("Starting Myflix server on Port 80 📽 ...\n\n")
	log.Fatal(http.ListenAndServe(":80", router))
}

func main() {

	// INIT MEILISEARCH


	err := db.InitMeilisearch("127.0.0.1", "7700", "MyApiKey")

	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}

	handleRequests()
}
