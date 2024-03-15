const { useState } = React;
import Swal from 'sweetalert2'
import ReactDOM from 'react-dom/client'
import withReactContent from 'sweetalert2-react-content'
import { FaStar, FaGoodreads } from "react-icons/fa";

function getClassName(genre) {
  const classMap = {
    "children": "children-color",
    "fantasy": "fantasy-color",
    "history_biography": "history_biography-color",
    "graphic_comics": "comics-color",
    "romance": "romance-color",
    "poetry": "poetry-color",
    "YA": "YA-color",
    "crime": "crime-color"
  };
  return classMap[genre.toLowerCase()] || "default_color"; // Use toLowerCase for case-insensitivity
}

const showDesc = (title, message) => {
  withReactContent(
    Swal.fire({
      title: title,
      text: message,
      icon: "info",
      width: '40rem',
      grow: "fullscreen"
    })
  )
}

export default function BookCard({ title, author, avg_rating, genres, description, imageUrl, url }) {
  return (
    <div className="book-card__container">
      <div className="book-card__cover">
        <img className="book-card__cover__image" src={imageUrl} alt={title} />
      </div>

      <div className="book-card__info-section">
        <div className="book-card__info-section__genre-section">
          {genres.map((genre) => (
            <div className={getClassName(genre) + " book-card__info-section__genre-section-container" + " flex-center"}>
              <span className='book-card__info-section__genre-section-conteiner-text'>#{genre}</span>
            </div>
          ))}
        </div>
    
            
        <h3 className="book-card__info-section__title">{title}</h3>
        <p className="book-card__info-section__author">by {author}</p>
        <div className="book-card__info-section__rating">
          <FaStar className='book-card__info-section__rating-icon' />
          <span className='book-card__info-section__rating-icon-rating'>{avg_rating}</span>
          
          <a href={url} target="_blank" rel="noopener noreferrer">
            <FaGoodreads className='book-card__info-section__rating-icon'/>
          </a>
        </div>
        <button
          className="book-card__info-section__show-description-btn btn btn-sm"
          onClick={() => showDesc(title, description)}
        >
          Show Description
        </button>
      </div>
    </div>
  );
}
