% Return the list of the Features given the ID of the Track
%getFeaturesList("0NKevst3QXMMXuV6Qch3GP", [A, B,C,R,T,Y,U,I]).
getFeaturesList(TrackID, [Dance, Energy, Speech, Acoustic, Instrumental, Live, Valence, Speed]) :-
    features(TrackID, Dance, Energy, Speech, Acoustic, Instrumental, Live, Valence, Speed).


% Given two ID return the similarity calculated with Jaccard on the Feature sets of the two tracks
similarityByTrackFeatures(TrackA,TrackB,Sim) :-
    getFeaturesList(TrackA, SimA),
    getFeaturesList(TrackB,SimB),
    jaccard(SimA,SimB,Sim).


%find all the ids of the tracks whose features match the features given in input.
% getTracksByFeatures("low_danceable", "high_energy", "low_valence", TenTracks).
getTracksByFeatures(N, Dance, Energy, Valence, NTracks) :-
    findall(TrackId, (features(TrackId, Dance, Energy, _, _, _, _,Valence, _)), Tracks),
    length(Tracks, N1),
    (
    N1 > N
    ->
    random_permutation(Tracks, TracksPer),
    take(TracksPer, N, NTracks)
    ;
    random_permutation(Tracks, NTracks)
    ).


getSimilarGenre([Genre], [ListGenre]) :- !,
    findall(G, (like(Genre, G)), ListGenre).

getSimilarGenre([Genre|GenreT], [ListGenre|ListGenreT]) :-
    findall(G, (like(Genre, G)), ListGenre),
    getSimilarGenre(GenreT, ListGenreT).

getArtistByGenres([Genre], [ListArtist]) :- !,
    findall(A, (artistgenres(A, Genre)), ListArtist).

getArtistByGenres([Genre|ListGenre], [ListArtist|ListArtistT]) :-
    findall(A, (artistgenres(A, Genre)), ListArtist),
    getArtistByGenres(ListGenre, ListArtistT).

getAlbumByArtist([ListArtist], [ListAlbum]) :- !,
    findall(A, (published_by(A, ListArtist)), ListAlbum).

getAlbumByArtist([ListArtist|ListArtistT], [ListAlbum|ListAlbumT]) :-
    findall(A, (published_by(A, ListArtist)), ListAlbum),
    getAlbumByArtist(ListArtistT, ListAlbumT).

getTrackByAlbum([ListAlbum], [ListTrack]) :- !,
    findall(A, (album_contains(ListAlbum, A)), ListTrack).

getTrackByAlbum([ListAlbum|ListAlbumT], [ListTrack|ListTrackT]) :-
    findall(A, (album_contains(ListAlbum, A)), ListTrack),
    getTrackByAlbum(ListAlbumT, ListTrackT).

getTrackByGenre(N, Genre, NTrack) :-
    getSimilarGenre(Genre, ListGenre),
    flatten(ListGenre, FlattenGenre),
    getArtistByGenres(FlattenGenre, ListArtist),
    flatten(ListArtist, FlattenA),
    list_to_set(FlattenA, Artist),
    getAlbumByArtist(Artist, ListAlbum),
    flatten(ListAlbum, FlattenAlbum),
    getTrackByAlbum(FlattenAlbum, ListTrack),
    flatten(ListTrack, FlattenTrack),
    random_permutation(FlattenTrack, Track), % compute a shuffle on the n*2 most similar tracks
    take(Track, N, NTrack).

%Given the list of the ID of the Tracks return the List of the name of the same tracks
getTrackName([], []).
getTrackName([H|T], [Track|T1]) :-
    track(H, Track),
    getTrackName(T, T1).


% getTrackIds(["treatment"], Name).
%Return the list of the tracks ID given the list of the tracks names
getTrackIds([], []).
getTrackIds([H|T], [Track|T1]) :-
    track(Track, H),
    getTrackIds(T, T1), !.

findMostSimilarTrackAggregate([TrackId],Tracks, [Similarity]) :-
    !,
    trackSimilarity(TrackId, Tracks, Similarity).


findMostSimilarTrackAggregate([TrackId|TracksIds], Tracks,[Similarity|TSimilarity]) :-
    trackSimilarity(TrackId, Tracks, Similarity),
    findMostSimilarTrackAggregate(TracksIds, Tracks, TSimilarity).


% Return a list with all the tracks ids in the kb  except the Track con cui voglio fare la similarità
getAllTracksExceptSome(TrackIds, TracksResults) :-
   findall(TrackId, (track(TrackId, _)), Tracks),
   subtract(Tracks, TrackIds, TracksResults).


% restituisce tutte le tracce con la loro similarità alla traccia data in input
trackSimilarity(TrackIdA, [TrackIdB], [Sim]) :-
    similarityByTrackFeatures(TrackIdA,TrackIdB,Sim), !.

trackSimilarity(TrackIdA, [TrackIdB|T], [Sim|SimT]) :-
    similarityByTrackFeatures(TrackIdA,TrackIdB,Sim),
    trackSimilarity(TrackIdA, T, SimT).


rankTrack(SimList, TracksList, ReversedTrack) :-
    list_list_pairs(SimList, TracksList, Pairs), % data la lista di tracce e similarità  ritorna la lista di coppie
    keysort(Pairs, OrderedPairs), % Sorting by the similarity (the key)
    pairs_values(OrderedPairs, OrderedTracks),
    reverse(OrderedTracks, ReversedTrack). % return the list only of the tracks


suggestTrack(TrackIds, N, NTracks) :-
    getAllTracksExceptSome(TrackIds, TracksTotal),
    findMostSimilarTrackAggregate(TrackIds,TracksTotal, Similarities),
    sum_list(Similarities, SumSimilarities),
    rankTrack(SumSimilarities, TracksTotal, OrderedTracks),
    N1 is N*2,
    take(OrderedTracks, N1, N1Tracks), % Take the first n*2 most similar tracks
    random_permutation(N1Tracks, TracksPer), % compute a shuffle on the n*2 most similar tracks
    take(TracksPer, N, NTracks).


% Prolog output
%?- retrieveAlbumByTrack(["76aNMPRl0MriIJx2gWRiwL"], A ).
%A = [∑(no 12k lg 17mif) new order + liam gillick: so it goes..].
retrieveAlbumByTrack([TrackIds], [Albums]) :- !, 
    album_contains(AlbumId, TrackIds), album(AlbumId, Albums). 


retrieveAlbumByTrack([TrackIds|T], [Albums|A]) :-
    album_contains(AlbumId, TrackIds), album(AlbumId, Albums),
    retrieveAlbumByTrack(T, A).