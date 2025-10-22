const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];

export function parseParamsFromUrl(uri = '') {
    // Regex to capture /widthxheight/filename.extension
    const regex = /^\/(\d+)x(\d+)\/([a-zA-Z0-9_-]+)\.([a-zA-Z0-9]+)$/i;
    const match = uri.match(regex);

    if (!match || match.length < 5) {
        // No match found for the given pattern
        return null;
    }

    const width = parseInt(match[1])
    const height = parseInt(match[2])
    const sourceImageFileName = match[3];
    const extension = match[4];

    // Validate the extension
    if (!validExtensions.includes(extension.toLowerCase())) {
        return null;
    }

    const options = {
        width,
        height,
        fit: 'cover',
        withoutEnlargement: true,
    }

    const sourceImageName = `${sourceImageFileName}.${extension}`

    return {
        options,
        sourceImageName: sourceImageName,
        originalKey: `${sourceImageName}`,
        extension,
    };
}

