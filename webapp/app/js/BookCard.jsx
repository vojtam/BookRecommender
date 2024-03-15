const { useState } = React;
import Swal from 'sweetalert2'
import ReactDOM from 'react-dom/client'
import withReactContent from 'sweetalert2-react-content'


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
  //const [showDescription, setShowDescription] = useState(false);

  //const toggleDescription = () => setShowDescription(!showDescription);

  return (
    <div className="book-card__container">
      <div className="book-card__cover">
        <img className="book-card__cover__image" src={imageUrl} alt={title} />
      </div>

      <div className="book-card__info-section">
        <div className="book-card__info-section__genre-section">
          {genres.map((genre) => (
             <span>#{genre}</span>
          ))}
    
        </div>
            
        <h3 className="book-card__info-section__title">{title}</h3>
        <p className="book-card__info-section__author">by {author}</p>
        <div className="book-card__info-section__rating">
          <i className="fas fa-star"></i>
          <span>{genres}</span>
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
