

function getClassName(genre) {
    const classMap = {
      "children": "children-color",
      "fantasy": "fantasy-color",
      "history_biography": "history_biography-color",
      "graphic_comics": "comics-color",
      "romance": "romance-color",
      "poetry": "poetry-color",
      "ya": "YA-color",
      "crime": "crime-color"
    };
    return classMap[genre.toLowerCase().trim()] || "default_color"; // Use toLowerCase for case-insensitivity
  }


export const GenreTag = (props) => {
    return (
      <div className={getClassName(props.genre) + " book-card__info-section__genre-section-container" + " flex-center"}>
        <span className='book-card__info-section__genre-section-conteiner-text'>#{props.genre}</span>
      </div>
    )
}