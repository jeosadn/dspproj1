function parse_metadata(metadata_string)
   %Message Parsing
   remain = metadata_string;
   [~, remain] = strtok(remain, '|');

   [Title, remain] = strtok(remain, '|');
   [Artist, remain] = strtok(remain, '|');
   [Author, remain] = strtok(remain, '|');
   [Album, remain] = strtok(remain, '|');
   [Date, remain] = strtok(remain, '|');
   [Invited, remain] = strtok(remain, '|');
   [Producer, remain] = strtok(remain, '|');

   fprintf('Los metadatos empotrados en el audio son los siguientes:\nTitulo: %s\nArtista: %s\nAutor: %s\nAlbum: %s\nFecha de publicacion: %s\nArtista invitado: %s\nProductor: %s\n', Title, Artist, Author, Album, Date, Invited, Producer);
