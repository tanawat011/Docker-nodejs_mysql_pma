# FROM ไว้กำหนดว่า Image ที่เราจะสร้าง ใช้ Image ไหนมาเป็นฐาน
FROM node:6.15.1-alpine
LABEL maintainer "Tanawat Pinthongpan"

# WORKDIR ไว้กำหนดว่าจะใช้ Path ไหนเป็น Working Directory
WORKDIR /nodeapp

# COPY ไว้นำไฟล์จากเครื่องของเรา ไปยัง Path ที่กำหนด
COPY . /nodeapp

# RUN เป็นการสั่ง Command ที่ต้องการรัน
# RUN npm install

# USER ไว้เปลี่ยน User ใน Container เป็น User อื่น (Image ของ Node.js ได้เตรียม User ชื่อ node ไว้ให้แล้ว)
# ช่วยในเรื่อง Security ถ้าไม่เปลี่ยน ก็จะถูกรันด้วย root ตามที่เห็นในหัวข้อแรก ๆ
# USER node

# EXPOSE ไว้ประกาศว่า Docker Image นี้ เมื่อสร้าง Container จะใช้ Port อะไรบ้าง
EXPOSE 3000

# CMD ไว้สำหรับกำหนดคำสั่ง Default ของ Container หากนำ Image ไปสร้าง โดยไม่ได้ระบุ Command ใด ๆ เพิ่มเติม
CMD ["npm", "start"]
