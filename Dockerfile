# FROM ไว้กำหนดว่า Image ที่เราจะสร้าง ใช้ Image ไหนมาเป็นฐาน
# (ระบุเวอร์ชันให้ชัด เพื่อให้ build ครั้งไหนก็ได้ผลเหมือนเดิม)
FROM node:26.13.1-alpine3.24
LABEL maintainer="Tanawat Pinthongpan"

# WORKDIR ไว้กำหนดว่าจะใช้ Path ไหนเป็น Working Directory
WORKDIR /nodeapp

# COPY ไว้นำไฟล์จากเครื่องของเรา ไปยัง Path ที่กำหนด
# คัดลอก package*.json ก่อน เพื่อให้ Docker cache ขั้น npm ci ไว้ ถ้า dependencies ไม่เปลี่ยน
COPY package.json package-lock.json ./

# RUN เป็นการสั่ง Command ที่ต้องการรัน
RUN npm ci --omit=dev && npm cache clean --force

COPY server.js ./

# USER ไว้เปลี่ยน User ใน Container เป็น User อื่น (Image ของ Node.js ได้เตรียม User ชื่อ node ไว้ให้แล้ว)
# ช่วยในเรื่อง Security ถ้าไม่เปลี่ยน ก็จะถูกรันด้วย root
USER node

# EXPOSE ไว้ประกาศว่า Docker Image นี้ เมื่อสร้าง Container จะใช้ Port อะไรบ้าง
EXPOSE 3000

# HEALTHCHECK ไว้บอก Docker ว่าจะเช็คยังไงว่า Container ยังทำงานปกติ
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD ["node", "-e", "fetch('http://127.0.0.1:3000/health').then(r => process.exit(r.ok ? 0 : 1), () => process.exit(1))"]

# CMD ไว้สำหรับกำหนดคำสั่ง Default ของ Container หากนำ Image ไปสร้าง โดยไม่ได้ระบุ Command ใด ๆ เพิ่มเติม
CMD ["node", "server.js"]
