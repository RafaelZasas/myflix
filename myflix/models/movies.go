package models

// Define the types for an article using a struct

type Movie struct {
	Title    string `json:"title,omitempty"`
	Year     string `json:"year,omitempty"`
	Plot     string `json:"plot,omitempty"`
	FullPlot string `json:"fullPlot"`
	Rated    string `json:"rated,omitempty"`
	Released string `json:"released,omitempty"`
	Runtime  string `json:"runtime,omitempty"`
	Genre    string `json:"genre,omitempty"`
	Director string `json:"director,omitempty"`
	Writer   string `json:"writer,omitempty"`
	Actors   string `json:"actors,omitempty"`
	Language string `json:"lanuage,omitempty"`
	Country  string `json:"country,omitempty"`
	Awards   string `json:"awards,omitempty"`
	Poster   string `json:"poster,omitempty"`
	Ratings  []struct {
		Source string `json:"source,omitempty"`
		Value  string `json:"value,omitempty"`
	}
	Metascore  string `json:"metascore,omitempty"`
	ImdbRating string `json:"imdbRating,omitempty"`
	ImdbVotes  string `json:"imdbVotes,omitempty"`
	ImdbId     string `json:"imdbId,omitempty"`
	Type       string `json:"type,omitempty"`
	DVD        string `json:"dvd,omitempty"`
	BoxOffice  string `json:"boxOffice,omitempty"`
	Production string `json:"production,omitempty"`
	Website    string `json:"website,omitempty"`
	Response   string `json:"response,omitempty"`
}
