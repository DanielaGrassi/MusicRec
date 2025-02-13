# insert at 1, 0 is the script path (or '' in REPL)
import os
import queries

def discretization(value):
    if "Tired" in value:
        value='low_energy'
    if "Normal" in value:
        value='medium_energy'
    if "Energic" in value:
        value='high_energy'
    if "Sad" in value:
        value='low_valence'
    if "Flat" in value:
        value='medium_valence'
    if "Happy" in value:
        value='high_valence'
    if "No" in value:
        value='low_danceable'
    if "Maybe..." in value:
        value='medium_danceable'
    if "YES!" in value:
        value='high_danceable'
    return value

def save_values(features):
    mood_parameters=[]
    for value in features:
        mood_parameters.append(discretization(value))
    return mood_parameters

def return_tracks(features):
    list_features = save_values(features)
    valence = list_features[0]
    energy = list_features[1]
    danceability = list_features[2]
    trackIds = queries.getTracksByFeatures(5, danceability, energy, valence)[0]['Tracks']
    tracksName = [tracks.replace("-", "").title() for tracks in queries.getTracksName(trackIds)[0]['Tracks']]
    Artists = [artist.title() for artist in queries.retrieveArtistsByID(trackIds)[0]['Artists']]
    result_string = list(map(' - '.join, zip(tracksName, Artists)))
    dict_tracks = {k: v for k, v in zip(result_string, trackIds)}
    return dict_tracks


def suggestionsTracks(trackids):
    suggestions_features = list(queries.suggestionTracks(trackids, 5))
    suggestions_features = suggestions_features[0]['NTracks']
    tracksName = [tracks.replace("-", "").title() for tracks in queries.getTracksName(suggestions_features)[0]['Tracks']]
    Artists = [artist.title() for artist in queries.retrieveArtistsByID(suggestions_features)[0]['Artists']]
    result_string = list(map(' - '.join, zip(tracksName, Artists)))
    dict_tracks = {k: v for k, v in zip(result_string, suggestions_features)}
    return dict_tracks

def suggestTracksByGenre(genres):
    suggestion_genres = queries.suggestTracksByGenre(5,genres)
    tracksName = [track.title() for track in list(queries.getTracksName(suggestion_genres[0]['Tracks'])[0]['Tracks'])]
    Artists = [artist.title() for artist in list(queries.retrieveArtistsByID(suggestion_genres[0]['Tracks'])[0]['Artists'])]
    result_string = list(map(' - '.join, zip(tracksName, Artists)))
    dict_tracks = {k: v for k, v in zip(result_string, (suggestion_genres[0]['Tracks']))}
    return dict_tracks

def suggestionArtists(trackids):
    suggestions = list(queries.suggestionArtist(trackids, 5))
    suggestions = suggestions[0]['N1Artists']
    return suggestions

def return_albums_by_artist(artist):
    albums_returned = queries.retrieveAlbumsByArtist(artist)
    #print(albums_returned)
    albums_returned=albums_returned[0]['Albums'][0]
    return albums_returned

def return_albums_by_track(trackid):
    print(trackid)
    albums_returned = queries.retrieveAlbumsByTrack(trackid)
    print(albums_returned)
    albums_returned=albums_returned[0]['Albums'][0]
    return albums_returned

if __name__ == '__main__':
    print(os.getcwd())
    results2 = return_albums_by_track(['0pN6uMiWfFJBhC1NIaNNDM'])
    print(results2)
