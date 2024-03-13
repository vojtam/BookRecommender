const { useState } = React;

export default function BookCard({ title, author, avg_rating, genres, description, imageUrl, url }) {
  const [showDescription, setShowDescription] = useState(false);

  const toggleDescription = () => setShowDescription(!showDescription);
  return (
    <div className="book-card">
      <img className="book-cover" src={imageUrl} alt={title} />
      <div className="info-section">
        <h3>{title}</h3>
        <p>by {author}</p>
        <span>average rating: {avg_rating}</span>
        <ul>
          <li key={genres}>{genres}</li>
        </ul>
        <button onClick={toggleDescription}>
          {showDescription ? 'Hide Description' : 'Show Description'}
        </button>
        {showDescription && <p className="description">{description}</p>}
      </div>
    </div>
  );
}
