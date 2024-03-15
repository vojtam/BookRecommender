const { useState } = React;

export default function BookCard({ title, author, avg_rating, genres, description, imageUrl, url }) {
  const [showDescription, setShowDescription] = useState(false);

  const toggleDescription = () => setShowDescription(!showDescription);
  return (
    <div className="book-card__container">
      <div className="book-card__cover">
        <img className="book-card__cover__image" src={imageUrl} alt={title} />
      </div>

      <div className="book-card__info-section">
        <div className="book-card__info-section__genre-section">
          <span>#{genres}</span>
        </div>
        <h3 className="book-card__info-section__title">{title}</h3>
        <p className="book-card__info-section__author">by {author}</p>
        <div className="book-card__info-section__rating">
          <i className="fas fa-star"></i>
          <span>{avg_rating}</span>
        </div>
        <button
          className="book-card__info-section__show-description-btn"
          onClick={toggleDescription}
        >
          {showDescription ? 'Hide Description' : 'Show Description'}
        </button>
        {showDescription && <p className="book-card__description">{description}</p>}
      </div>
    </div>
  );
}
