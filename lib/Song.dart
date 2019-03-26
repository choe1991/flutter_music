class Song {
  final int songid;
  final String name;
  final String artistName;
 
  Song({
    this.songid,
    this.name,
    this.artistName
  });
 
  Song.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        artistName = json['artists'][0]['name'],
        songid = json['id'];


}