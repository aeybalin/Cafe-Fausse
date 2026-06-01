import React, { useState } from "react";
import "./Gallery.css";

/* =========================================================
   IMPORT GALLERY IMAGES
   All files should be stored in: src/assets/gallery/
========================================================= */
import storeFront from "../assets/gallery/store-front.png";
import risotto from "../assets/gallery/risotto.png";
import ribeye from "../assets/gallery/ribeye.png";
import tiramisu from "../assets/gallery/tiramisu.png";
import cheesecake from "../assets/gallery/cheesecake.png";
import bruschetta from "../assets/gallery/bruschetta.png";
import caesarSalad from "../assets/gallery/caesar-salad.png";
import event from "../assets/gallery/event.png";

/* =========================================================
   IMPORT JSON DATA
========================================================= */
import awardsData from "../data/awards.json";
import reviewsData from "../data/reviews.json";

function Gallery() {
  /* =====================================================
     IMAGE LIST
     This is the order in which the carousel displays images
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
     CURRENT IMAGE INDEX
  ====================================================== */
  const [currentIndex, setCurrentIndex] = useState(0);

  /* =====================================================
     LIGHTBOX STATE
  ====================================================== */
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);

  /* =====================================================
     GO TO PREVIOUS IMAGE
  ====================================================== */
  function goToPrevious() {
    setCurrentIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
  }

  /* =====================================================
     GO TO NEXT IMAGE
  ====================================================== */
  function goToNext() {
    setCurrentIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
  }

  return (
    <div className="gallery-page">
      {/* =====================================================
          MAIN GALLERY IMAGE AREA
      ====================================================== */}
      <div className="gallery-main">
        {/* Main image container */}
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
          {/* Left arrow */}
          <button className="gallery-arrow" onClick={goToPrevious}>
            ‹
          </button>

          {/* Dots */}
          <div className="gallery-dots">
            {images.map((_, index) => (
              <button
                key={index}
                className={`gallery-dot ${index === currentIndex ? "active" : ""}`}
                onClick={() => setCurrentIndex(index)}
                aria-label={`Go to image ${index + 1}`}
              />
            ))}
          </div>

          {/* Right arrow */}
          <button className="gallery-arrow" onClick={goToNext}>
            ›
          </button>
        </div>
      </div>

      {/* =====================================================
          LIGHTBOX OVERLAY
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
            {/* LEFT ARROW */}
            <button
              className="lightbox-arrow lightbox-arrow-left"
              onClick={goToPrevious}
            >
              ‹
            </button>

            {/* ENLARGED IMAGE */}
            <img
              src={images[currentIndex]}
              alt={`Enlarged ${currentIndex + 1}`}
              className="lightbox-image"
            />

            {/* RIGHT ARROW */}
            <button
              className="lightbox-arrow lightbox-arrow-right"
              onClick={goToNext}
            >
              ›
            </button>
          </div>
        </div>
      )}

      {/* =====================================================
          BOTTOM 2-COLUMN SECTION
          Awards + Reviews from JSON
      ====================================================== */}
      <div className="gallery-bottom-grid">
        {/* ================= AWARDS ================= */}
        <div className="gallery-info-card">
          <h3 className="gallery-info-title">AWARDS</h3>

          {awardsData.awards.map((award, index) => (
            <p key={index} className="gallery-info-text">
              {award.name}
              {award.source ? ` – ${award.source}` : ""} – {award.year}
            </p>
          ))}
        </div>

        {/* ================= CUSTOMER REVIEWS ================= */}
        <div className="gallery-info-card">
          <h3 className="gallery-info-title">CUSTOMER REVIEWS</h3>

          {reviewsData.reviews.map((review, index) => (
            <div key={index}>
              <p className="gallery-review-quote">“{review.quote}”</p>
              <p className="gallery-review-source">{review.source}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Gallery;