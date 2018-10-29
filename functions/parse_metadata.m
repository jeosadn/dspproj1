function parse_metadata(metadata_string)
    remain = metadata_string;
    [~, remain] = strtok(remain, '|');

    [Title, remain] = strtok(remain, '|');
    [Artist, remain] = strtok(remain, '|');
    [Author, remain] = strtok(remain, '|');
    [Album, remain] = strtok(remain, '|');
    [Date, remain] = strtok(remain, '|');
    [Invited, remain] = strtok(remain, '|');
    [Producer, remain] = strtok(remain, '|');

    if (strcmp(Title, ''))
        fprintf('Error: no se encontro titulo codificado');
    end
    if (strcmp(Artist, ''))
        fprintf('Error: no se encontro artista codificado');
    end
    if (strcmp(Author, ''))
        fprintf('Error: no se encontro autor codificado');
    end
    if (strcmp(Album, ''))
        fprintf('Error: no se encontro album codificado');
    end
    if (strcmp(Date, ''))
        fprintf('Error: no se encontro fecha de publicacion codificado');
    end
    if (strcmp(Invited, ''))
        fprintf('Error: no se encontro artista invitado codificado');
    end
    if (strcmp(Producer, ''))
        fprintf('Error: no se encontro productor codificado');
    end

    fprintf('Los metadatos empotrados en el audio son los siguientes:\nTitulo: %s\nArtista: %s\nAutor: %s\nAlbum: %s\nFecha de publicacion: %s\nArtista invitado: %s\nProductor: %s\n', Title, Artist, Author, Album, Date, Invited, Producer);
end
