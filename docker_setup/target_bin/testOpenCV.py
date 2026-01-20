import cv2

print('Unit test for OpenCV')

# Prova ad aprire la videocamera
cap = cv2.VideoCapture(0)

# Verifica se la videocamera è stata aperta correttamente
if not cap.isOpened():
    print("La videocamera non è disponibile. Utilizzo lo stream mp4.")

    # URL dello stream mp4
    stream_url = "https://file-examples.com/wp-content/storage/2017/04/file_example_MP4_480_1_5MG.mp4"

    # Apri lo stream mp4
    cap = cv2.VideoCapture(stream_url)

# Loop per leggere i frame dal video
while True:
    # Leggi il frame corrente
    ret, frame = cap.read()

    # Verifica se il frame è stato letto correttamente
    if not ret:
        print("Errore durante la lettura del frame.")
        break

    # Mostra il frame a schermo
    cv2.imshow("Video", frame)

    # Esci dal loop se viene premuto il tasto 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Rilascia le risorse
cap.release()
cv2.destroyAllWindows()