import React, { useState } from "react";
import "./Gallery.css";

/* ================= GALLERY IMAGES ================= */
import storeFront from "../assets/gallery/store-front.png";
import risotto from "../assets/gallery/risotto.png";
import ribeye from "../assets/gallery/ribeye.png";
import tiramisu from "../assets/gallery/tiramisu.png";
import cheesecake from "../assets/gallery/cheesecake.png";
import bruschetta from "../assets/gallery/bruschetta.png";
import caesarSalad from "../assets/gallery/caesar-salad.png";
import event from "../assets/gallery/event.png";

/* ================= AWARD LOGOS =================
*/
import culinaryExcellenceAward from "../assets/awards/culinary-excellence-award-2022.png";
import restaurantOfTheYearAward from "../assets/awards/restaurant-year-award-2023.png";
import bestFineDiningAward from "../assets/awards/best-fine-dining-award-2023.png";

/* ================= DATA ================= */
import awardsData from "../data/awards.json";
import reviewsData from "../data/reviews.json";

function Gallery() {
  /* =====================================================
     IMAGE LIST
  ====================================================== */
  const images = [
    storeFront,
    risotto,
    ribeye,
    tiramisu,
    cheesecake,
    bruschetta,
    caesarSalad,
    event,
  ];

  /* =====================================================
     AWARD LOGOS
     These are matched to awardsData.awards by index.
     Make sure awards.json is in this order:
     1. Culinary Excellence Award – 2022
     2. Best Seasonal Menu Award – 2023
     3. Critics' Choice Award – 2022
  ====================================================== */
  const awardLogos = [
    {
      src: culinaryExcellenceAward,
      alt: "Culinary Excellence Award 2022",
    },
    {
    src: restaurantOfTheYearAward,
    alt: "Restaurant of the Year 2023",
    },
    {
    src: bestFineDiningAward,
    alt: "Best Fine Dining Award 2023",
    },

  ];

  /* =====================================================
     STATE
  ====================================================== */
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);

  /* =====================================================
     CAROUSEL NAVIGATION
  ====================================================== */
  function goToPrevious() {
    setCurrentIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
  }

  function goToNext() {
    setCurrentIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
  }

  return (
    <div className="gallery-page">
      {/* =====================================================
          MAIN GALLERY IMAGE AREA
      ====================================================== */}
      <div className="gallery-main">
        <div className="gallery-image-frame">
          <img
            src={images[currentIndex]}
            alt={`Gallery ${currentIndex + 1}`}
            className="gallery-main-image"
            onClick={() => setIsLightboxOpen(true)}
          />
        </div>

        {/* =================================================
            CAROUSEL CONTROLS
        ================================================= */}
        <div className="gallery-controls">
          <button
            type="button"
            className="gallery-arrow"
            onClick={goToPrevious}
            aria-label="Previous gallery image"
          >
            ‹
          </button>

          <div className="gallery-dots">
            {images.map((_, index) => (
              <button
                key={index}
                type="button"
                className={`gallery-dot ${index === currentIndex ? "active" : ""}`}
                onClick={() => setCurrentIndex(index)}
                aria-label={`Go to image ${index + 1}`}
              />
            ))}
          </div>

          <button
            type="button"
            className="gallery-arrow"
            onClick={goToNext}
            aria-label="Next gallery image"
          >
            ›
          </button>
        </div>
      </div>

      {/* =====================================================
          LIGHTBOX
      ====================================================== */}
      {isLightboxOpen && (
  <div
    className="lightbox-overlay"
    onClick={() => setIsLightboxOpen(false)}
  >
    <div
      className="lightbox-content"
      onClick={(e) => e.stopPropagation()}
    >
      {/* ✅ CLOSE BUTTON (X) */}
      <button
        className="lightbox-close"
        onClick={() => setIsLightboxOpen(false)}
        aria-label="Close"
      >
        ×
      </button>

      {/* ✅ LEFT ARROW */}
      <button
        type="button"
        className="lightbox-arrow lightbox-arrow-left"
        onClick={goToPrevious}
        aria-label="Previous enlarged image"
      >
        ‹
      </button>

      {/* ✅ IMAGE */}
      <img
        src={images[currentIndex]}
        alt={`Enlarged gallery image ${currentIndex + 1}`}
        className="lightbox-image"
      />

      {/* ✅ RIGHT ARROW */}
      <button
        type="button"
        className="lightbox-arrow lightbox-arrow-right"
        onClick={goToNext}
        aria-label="Next enlarged image"
      >
        ›
      </button>
    </div>
  </div>
)}

      {/* =====================================================
          AWARDS + REVIEWS
      ====================================================== */}
      <section className="gallery-awards-reviews-section">
        <div className="gallery-bottom-grid">
          {/* ================= AWARDS ================= */}
          <div className="gallery-info-card gallery-info-card-awards">
            <h4 className="gallery-info-title">AWARDS</h4>

            <div className="gallery-awards-list">
              {awardsData.awards.map((award, index) => (
                <div key={index} className="gallery-award-item">
                  <div className="gallery-award-text-block">
                    <p className="gallery-award-name">{award.name}</p>
                    <p className="gallery-award-meta">
                      {award.source ? `${award.source} – ` : ""}
                      {award.year}
                    </p>
                  </div>

                  {awardLogos[index] && (
                    <img
                      src={awardLogos[index].src}
                      alt={awardLogos[index].alt}
                      className="award-logo"
                    />
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* ================= REVIEWS ================= */}
          <div className="gallery-info-card gallery-info-card-reviews">
            <h4 className="gallery-info-title">CUSTOMER REVIEWS</h4>

            {reviewsData.reviews.map((review, index) => (
              <div key={index} className="gallery-review-block">
                <p className="gallery-review-quote">“{review.quote}”</p>
                <p className="gallery-review-source">{review.source}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

export default Gallery;